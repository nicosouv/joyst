#!/bin/bash
set -e

# Get inputs
CURRENT_VERSION="$1"
NEW_VERSION="$2"
BRANCH_NAME="$3"

echo "Creating release for version: $NEW_VERSION"

# Create release notes based on branch type
if [[ $BRANCH_NAME == feat/* ]]; then
    RELEASE_NOTES="🚀 **New Feature**

Branch: \`$BRANCH_NAME\`
Type: Feature addition (MINOR version bump)

### Changes
$(git log --oneline $CURRENT_VERSION..HEAD)"

elif [[ $BRANCH_NAME == fix/* ]]; then
    RELEASE_NOTES="🐛 **Bug Fix**

Branch: \`$BRANCH_NAME\`
Type: Bug fix (PATCH version bump)

### Changes
$(git log --oneline $CURRENT_VERSION..HEAD)"

elif [[ $BRANCH_NAME == breaking/* ]] || [[ $BRANCH_NAME == major/* ]]; then
    RELEASE_NOTES="💥 **Breaking Change**

Branch: \`$BRANCH_NAME\`
Type: Breaking change (MAJOR version bump)

⚠️ **This release contains breaking changes**

### Changes
$(git log --oneline $CURRENT_VERSION..HEAD)"

else
    RELEASE_NOTES="📦 **Release**

Branch: \`$BRANCH_NAME\`
Type: General update (PATCH version bump)

### Changes
$(git log --oneline $CURRENT_VERSION..HEAD)"
fi

# Create tag
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git tag -a "$NEW_VERSION" -m "Release $NEW_VERSION"
git push origin "$NEW_VERSION"

# Create GitHub release
gh release create "$NEW_VERSION" \
  --title "Release $NEW_VERSION" \
  --notes "$RELEASE_NOTES"

echo "Release $NEW_VERSION created successfully"