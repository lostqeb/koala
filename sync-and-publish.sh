#!/bin/bash

set -e

SOURCE_DIR="$HOME/Projects/koala/"
TARGET_DIR="$HOME/builds/aur/koala/"
MAX_SIZE=480

echo "🔍 Previewing changes from $SOURCE_DIR to $TARGET_DIR..."
rsync -av --delete \
  --exclude '*.log' \
  --exclude '*.zst' \
  --exclude '*.tar.*' \
  --exclude 'pkg/' \
  --exclude 'src/' \
  --exclude '.git/' \
  "$SOURCE_DIR" "$TARGET_DIR" --dry-run

read -p "⚠️ Proceed with real sync and publish? (y/N): " confirm
[[ "$confirm" != "y" && "$confirm" != "Y" ]] && echo "❌ Aborted." && exit 1

echo "🔄 Syncing source..."
rsync -av --delete \
  --exclude '*.log' \
  --exclude '*.zst' \
  --exclude '*.tar.*' \
  --exclude 'pkg/' \
  --exclude 'src/' \
  --exclude '.git/' \
  "$SOURCE_DIR" "$TARGET_DIR"

cd "$TARGET_DIR" || { echo "❌ Target directory not found"; exit 1; }

# Ensure on 'master' branch
branch=$(git rev-parse --abbrev-ref HEAD)
[[ "$branch" != "master" ]] && git branch -m "$branch" master

# Compress .ogg files if oversized
echo "🗜 Checking .ogg file sizes..."
for file in *.ogg; do
  [[ -f "$file" ]] || continue
  size_kb=$(du -k "$file" | cut -f1)
  if (( size_kb > MAX_SIZE )); then
    echo "Compressing $file..."
    ffmpeg -y -i "$file" -c:a libvorbis -b:a 64k "$file"
  fi
done

# Compress koala_icon.png if too big
if [[ -f koala_icon.png ]]; then
  png_kb=$(du -k koala_icon.png | cut -f1)
  if (( png_kb > MAX_SIZE )); then
    echo "🖼 Compressing koala_icon.png..."
    magick convert koala_icon.png -resize 128x128 -strip -quality 85 koala_icon.png
  fi
fi

# Clean up build artifacts from Git
git rm -rf --cached pkg/ src/ *.pkg.tar.* 2>/dev/null || true

# Ensure .gitignore
cat > .gitignore <<EOF
pkg/
src/
*.log
*.pkg.tar.*
sync-and-publish.sh
generate-changelog.sh
CHANGELOG.md
EOF
git add .gitignore

# Regenerate .SRCINFO
echo "📄 Regenerating .SRCINFO..."
makepkg --printsrcinfo > .SRCINFO
git add .SRCINFO

# Generate changelog if available
[[ -x ./generate-changelog.sh ]] && ./generate-changelog.sh && git add CHANGELOG.md

# Commit and push
git add .
git commit -m "Automated AUR sync on $(date +'%Y-%m-%d %H:%M')"
git push --force origin master

echo "✅ Koala synced and pushed to AUR successfully."
