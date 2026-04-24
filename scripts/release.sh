#!/usr/bin/env bash
# Usage: ./scripts/release.sh <patch|minor|major>
# Example: ./scripts/release.sh patch   → 1.0.0 → 1.0.1
#          ./scripts/release.sh minor   → 1.0.0 → 1.1.0
#          ./scripts/release.sh major   → 1.0.0 → 2.0.0
#
# Bumps pubspec.yaml, commits, tags, and pushes — triggering the
# GitHub Actions release workflow automatically.

set -euo pipefail

BUMP="${1:-}"
PUBSPEC="pubspec.yaml"
ALLOWED_BRANCH="main"

# ── Preflight checks ──────────────────────────────────────────────────────────

if [[ -z "$BUMP" ]] || [[ ! "$BUMP" =~ ^(patch|minor|major)$ ]]; then
  echo "Usage: $0 <patch|minor|major>"
  exit 1
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" != "$ALLOWED_BRANCH" ]]; then
  echo "Error: must be on '$ALLOWED_BRANCH', currently on '$CURRENT_BRANCH'"
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Error: working tree is not clean — commit or stash changes first"
  git status --short
  exit 1
fi

# ── Compute new version ───────────────────────────────────────────────────────

CURRENT_VERSION=$(grep '^version:' "$PUBSPEC" | sed 's/version: //;s/+.*//')
CURRENT_BUILD=$(grep '^version:' "$PUBSPEC" | sed 's/.*+//')

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

case "$BUMP" in
  patch) PATCH=$((PATCH + 1)) ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
NEW_BUILD=$((CURRENT_BUILD + 1))
TAG="v${NEW_VERSION}"

# ── Check tag doesn't already exist ──────────────────────────────────────────

if git rev-parse --verify "refs/tags/${TAG}" &>/dev/null; then
  echo "Error: tag ${TAG} already exists locally"
  exit 1
fi

if git ls-remote --exit-code --tags origin "refs/tags/${TAG}" &>/dev/null; then
  echo "Error: tag ${TAG} already exists on origin"
  exit 1
fi

# ── Pre-flight quality checks (same as Husky pre-commit) ─────────────────────

echo "Running pre-commit checks before mutating pubspec.yaml..."
dart format --set-exit-if-changed . || { echo "Error: dart format failed — fix formatting first"; exit 1; }
flutter analyze || { echo "Error: flutter analyze failed — fix issues first"; exit 1; }

# ── Apply version bump (with rollback on failure) ─────────────────────────────

echo "Bumping: ${CURRENT_VERSION}+${CURRENT_BUILD} → ${NEW_VERSION}+${NEW_BUILD}"

ORIGINAL_VERSION_LINE=$(grep '^version:' "$PUBSPEC")
rollback() {
  echo "Rolling back pubspec.yaml..."
  TMPFILE=$(mktemp)
  sed "s/^version: .*/$(echo "$ORIGINAL_VERSION_LINE" | sed 's/version: //')/" "$PUBSPEC" > "$TMPFILE"
  mv "$TMPFILE" "$PUBSPEC"
}
trap rollback ERR

TMPFILE=$(mktemp)
sed "s/^version: .*/version: ${NEW_VERSION}+${NEW_BUILD}/" "$PUBSPEC" > "$TMPFILE"
mv "$TMPFILE" "$PUBSPEC"

# ── Commit, tag, push ─────────────────────────────────────────────────────────

git commit --only "$PUBSPEC" -m "chore(release): bump version to ${NEW_VERSION}"
git tag -a "$TAG" -m "Release ${TAG}"
git push origin HEAD --tags

trap - ERR

echo ""
echo "✓ Tag ${TAG} pushed — GitHub Actions release workflow starting."
echo "  https://github.com/cmacera/serapeum-app/actions"
