#!/bin/bash

# Paths
SOURCE_DIR="$HOME/Projects/koala/"
TARGET_DIR="$HOME/builds/aur/koala/"

# Preview with dry-run
echo "🔍 Preview of changes (dry run):"
rsync -av --delete --dry-run \
  --exclude '*.log' \
  --exclude '*.zst' \
  --exclude '*.tar.*' \
  --exclude 'pkg/' \
  --exclude 'src/' \
  --exclude '.git/' \
  "$SOURCE_DIR" "$TARGET_DIR"

# Confirm before syncing
read -p "⚠️ Proceed with real sync and publish? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "❌ Sync canceled."
  exit 1
fi

# Sync files for real
echo "🔄 Syncing source to AUR package directory..."
rsync -av --delete \
  --exclude '*.log' \
  --exclude '*.zst' \
  --exclude '*.tar.*' \
  --exclude 'pkg/' \
  --exclude 'src/' \
  --exclude '.git/' \
  "$SOURCE_DIR" "$TARGET_DIR"

# Change into AUR build directory
cd "$TARGET_DIR" || exit 1

# Auto-bump pkgrel
echo "🔢 Bumping pkgrel..."
sed -i -E 's/^pkgrel=([0-9]+)/pkgrel=$((\1+1))/' PKGBUILD

# Optionally bump pkgver using current date (uncomment to use date versioning)
# NEW_VER=$(date +'%Y.%m.%d')
# sed -i "s/^pkgver=.*/pkgver=$NEW_VER/" PKGBUILD

# Regenerate .SRCINFO
echo "📄 Regenerating .SRCINFO..."
makepkg --printsrcinfo > .SRCINFO


# Generate or update changelog
if [[ -f generate-changelog.sh ]]; then
  echo "📝 Generating changelog..."
  ./generate-changelog.sh
else
  echo "⚠️ No changelog script found, skipping."
fi

# Git add, commit, and push
echo "📤 Committing and pushing to AUR..."
git add .
git commit -m "Automated update on $(date +'%Y-%m-%d %H:%M')"
git push origin master

echo "✅ Koala successfully synced and pushed to AUR."
