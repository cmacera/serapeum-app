#!/usr/bin/env bash
# Usage: ./scripts/release.sh <version>
# Example: ./scripts/release.sh 1.1.0
#
# Bumps pubspec.yaml version, commits, tags, and pushes — triggering the
# GitHub Actions release workflow automatically.

set -euo pipefail

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <version>  (e.g. $0 1.1.0)"
  exit 1
fi

if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: version must be semver (e.g. 1.1.0), got: $VERSION"
  exit 1
fi

PUBSPEC="pubspec.yaml"

# Extract current build number and increment
CURRENT_BUILD=$(grep '^version:' "$PUBSPEC" | sed 's/.*+//')
NEXT_BUILD=$((CURRENT_BUILD + 1))

# Write new version line
sed -i '' "s/^version: .*/version: ${VERSION}+${NEXT_BUILD}/" "$PUBSPEC"

echo "Bumped pubspec.yaml → version: ${VERSION}+${NEXT_BUILD}"

git add "$PUBSPEC"
git commit -m "chore(release): bump version to ${VERSION}"
git tag "v${VERSION}"
git push origin HEAD --follow-tags

echo ""
echo "Tag v${VERSION} pushed — GitHub Actions release workflow starting."
echo "https://github.com/cmacera/serapeum-app/actions"
