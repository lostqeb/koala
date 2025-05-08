#!/bin/bash

# Define your source and target folders
SOURCE_DIR="$HOME/Projects/koala/"
TARGET_DIR="$HOME/builds/aur/koala/"

# Perform a dry run first for safety
echo "🔍 Preview of changes:"
rsync -av --delete --dry-run "$SOURCE_DIR" "$TARGET_DIR"

# Confirm before syncing
read -p "⚠️ Proceed with sync? (y/N): " confirm
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
  echo "🔁 Syncing files now..."
  rsync -av --delete "$SOURCE_DIR" "$TARGET_DIR"
  echo "✅ Sync complete."
else
  echo "❌ Sync canceled."
fi
