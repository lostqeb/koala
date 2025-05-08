#!/bin/bash

# === Config ===
BUILD_DIR="$HOME/koala/builds"
EXTRACT_DIR="$HOME/koala/test-extract"
LATEST_PACKAGE=$(ls -1t "$BUILD_DIR"/koala-*.tar.gz | head -n 1)

# === Verify package exists ===
if [ ! -f "$LATEST_PACKAGE" ]; then
  echo "❌ No koala package found in $BUILD_DIR"
  exit 1
fi

echo "📦 Verifying package: $LATEST_PACKAGE"

# === Clean and extract ===
rm -rf "$EXTRACT_DIR"
mkdir -p "$EXTRACT_DIR"
tar -xvzf "$LATEST_PACKAGE" -C "$EXTRACT_DIR"

# === Check essential files ===
echo "🔍 Checking contents..."

REQUIRED_FILES=(
  "koala/bin/system-backup.sh"
  "koala/systemd/system-backup.service"
  "koala/systemd/system-backup.timer"
  "koala/themes/index.theme"
)

ALL_OK=true

for file in "${REQUIRED_FILES[@]}"; do
  if [ -f "$EXTRACT_DIR/$file" ]; then
    echo "✅ Found: $file"
  else
    echo "❌ Missing: $file"
    ALL_OK=false
  fi
done

# === Show folder tree ===
echo -e "\n📂 Directory structure:"
tree -C "$EXTRACT_DIR/koala" || find "$EXTRACT_DIR/koala" -type f

# === Final result ===
if [ "$ALL_OK" = true ]; then
  echo -e "\n🎉 All required files are present!"
else
  echo -e "\n⚠️ Some required files are missing. Check your packaging script."
fi
