#!/bin/bash

# === Metadata ===
TODAY=$(date +%Y-%m-%d)
KOALA_ROOT="$HOME/koala"
ARCHIVE_NAME="$KOALA_ROOT/builds/koala-$TODAY.tar.gz"
LOGFILE="$KOALA_ROOT/koala.log"

# === Source paths ===
SCRIPT_DIR="$HOME/scripts"
SYSTEMD_DIR="$HOME/.config/systemd/user"
SOUNDS_DIR="$HOME/.local/share/koala/sounds"

# === Destination paths inside the package ===
DEST_SCRIPTS="$KOALA_ROOT/scripts"
DEST_SYSTEMD="$KOALA_ROOT/systemd"
DEST_SOUNDS="$KOALA_ROOT/sounds"
BUILD_DIR="$KOALA_ROOT/builds"

# === Ensure directories exist ===
mkdir -p "$DEST_SCRIPTS" "$DEST_SYSTEMD" "$DEST_SOUNDS" "$BUILD_DIR"

# === Log start ===
echo "📦 [$TODAY] Building koala package..." >> "$LOGFILE"

# === Copy scripts ===
cp "$SCRIPT_DIR/system-backup.sh" "$DEST_SCRIPTS/"

# === Copy systemd units (safe glob) ===
for file in "$SYSTEMD_DIR"/system-backup.*; do
  [ -e "$file" ] && cp "$file" "$DEST_SYSTEMD/"
done

# === Copy sound theme ===
cp "$HOME/.local/share/koala/themes/index.theme" "$KOALA_ROOT/sounds/"

# === Copy sound files (safe glob) ===
for file in "$SOUNDS_DIR"/*.ogg; do
  [ -e "$file" ] && cp "$file" "$DEST_SOUNDS/"
done

# === Include verifier script
# cp "$KOALA_ROOT/verify-koala-package.sh" "$KOALA_ROOT/"

# === Package it ===
tar -czvf "$ARCHIVE_NAME" --exclude="$KOALA_ROOT/builds" -C "$HOME" koala >> "$LOGFILE" 2>&1

# === Prune old builds (keep 4 most recent) ===
echo "🧹 Pruning old builds..." >> "$LOGFILE"
ls -1t "$BUILD_DIR"/koala-*.tar.gz | tail -n +5 | xargs -r rm --

# === Log success ===
echo "✅ [$TODAY] Created: $ARCHIVE_NAME" >> "$LOGFILE"
echo "-----------------------------------------------" >> "$LOGFILE"
