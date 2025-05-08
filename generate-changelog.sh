#!/bin/bash

# Navigate to your repo (assumes run from AUR repo root)
cd "$(dirname "$0")"

# Ensure we're in a Git repo
if [ ! -d .git ]; then
  echo "❌ Not a Git repository."
  exit 1
fi

# Get the last tag or fall back to initial commit
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)

echo "📄 Generating changelog since: $LAST_TAG"

# Generate the changelog entries
echo -e "\n## $(date +'%Y-%m-%d %H:%M')" >> CHANGELOG.md
git log --pretty=format:"- %s" "$LAST_TAG"..HEAD >> CHANGELOG.md

echo "✅ CHANGELOG.md updated."
