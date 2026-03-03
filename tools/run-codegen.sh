#!/bin/bash
#
# run-codegen.sh
#
# Generates reference Dart model files from docs/openapi.yaml using the
# openapi-generator-cli.jar bundled in this tools/ directory.
#
# Output: lib/generated/models/  (reference only — not imported directly)
#
# Usage:
#   ./tools/run-codegen.sh
#
# Workflow:
#   1. npm run sync:flutter (in serapeum-api) — copies updated openapi.yaml here
#   2. ./tools/run-codegen.sh               — generates reference models
#   3. Compare lib/generated/models/ with lib/features/discovery/data/models/
#      and update the hand-written DTOs for any new/changed fields.
#   4. dart run build_runner build --delete-conflicting-outputs

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

JAR="$SCRIPT_DIR/openapi-generator-cli.jar"
SPEC="$PROJECT_ROOT/docs/openapi.yaml"
CONFIG="$SCRIPT_DIR/openapi-config.yaml"
OUTPUT_DIR="$PROJECT_ROOT/lib/generated/models"
TMP_DIR="$(mktemp -d)"

# Verify prerequisites
if ! command -v java &>/dev/null; then
  echo "❌ Java not found. Install Java 11+ to run the OpenAPI generator."
  exit 1
fi

if [ ! -f "$JAR" ]; then
  echo "❌ openapi-generator-cli.jar not found at $JAR"
  exit 1
fi

if [ ! -f "$SPEC" ]; then
  echo "❌ OpenAPI spec not found at $SPEC"
  echo "   Run 'npm run sync:flutter' in serapeum-api first."
  exit 1
fi

if [ ! -f "$CONFIG" ]; then
  echo "❌ OpenAPI config not found at $CONFIG"
  echo "   Create tools/openapi-config.yaml or check the path."
  exit 1
fi

echo "🔧 Generating reference models from $SPEC ..."

java -jar "$JAR" generate \
  -i "$SPEC" \
  -g dart-dio \
  -o "$TMP_DIR" \
  --global-property models \
  --model-name-suffix Dto \
  -c "$CONFIG" \
  2>&1 | grep -v "^\[main\]" | grep -v "^$" || true
# || true prevents set -e/pipefail from triggering on grep -v "^$" exiting 1
# (empty output); PIPESTATUS still captures java's actual exit code.
JAVA_EXIT="${PIPESTATUS[0]}"
if [ "$JAVA_EXIT" -ne 0 ]; then
  echo "❌ openapi-generator failed (exit $JAVA_EXIT)" >&2
  exit "$JAVA_EXIT"
fi

# dart-dio outputs to lib/src/model or lib/model depending on version
GENERATED_DIR="$TMP_DIR/lib/src/model"
if [ ! -d "$GENERATED_DIR" ]; then
  GENERATED_DIR="$TMP_DIR/lib/model"
fi

if [ ! -d "$GENERATED_DIR" ]; then
  echo "❌ Could not find generated models in $TMP_DIR"
  exit 1
fi

# Verify .dart files exist before wiping OUTPUT_DIR (preserves prior output on failure)
if ! ls "$GENERATED_DIR"/*.dart &>/dev/null; then
  echo "❌ No .dart files found in $GENERATED_DIR — generator produced no output" >&2
  exit 1
fi

# Replace reference output (clean slate each run)
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
cp "$GENERATED_DIR"/*.dart "$OUTPUT_DIR/"

# Cleanup
rm -rf "$TMP_DIR"

echo ""
echo "✅ Reference models written to: $OUTPUT_DIR"
echo ""
echo "   Review the generated files for new/changed fields, then update"
echo "   lib/features/discovery/data/models/ accordingly."
echo ""
echo "   Run after updating DTOs:"
echo "   dart run build_runner build --delete-conflicting-outputs"
