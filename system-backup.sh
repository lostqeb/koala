#!/bin/bash
[[ -x /usr/share/koala/koala-init.sh ]] && /usr/share/koala/koala-init.sh > /dev/null 2>&1

# Load config
CONFIG_FILE="$HOME/.local/share/koala-backup/config/config.conf"
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  echo "❌ Config file not found: $CONFIG_FILE"
  exit 1
fi

# Ensure backup destination exists
BACKUP_DEST="${BACKUP_DEST:-$HOME/Desktop/Koala-Backups}"\n\nmkdir -p "$BACKUP_DEST"

# Create timestamped backup
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="backup_$TIMESTAMP.tar.gz"
BACKUP_PATH="$BACKUP_DEST/$BACKUP_NAME"

# Run the backup
if tar -czf "$BACKUP_PATH" "$BACKUP_SOURCE"; then
  echo "✅ Backup created: $BACKUP_PATH"

  # Clean up old backups
  BACKUP_COUNT=$(ls -1 "$BACKUP_DEST"/backup_*.tar.gz 2>/dev/null | wc -l)
  if (( BACKUP_COUNT > RETENTION_COUNT )); then
    echo "🧹 Removing old backups..."
    ls -1t "$BACKUP_DEST"/backup_*.tar.gz | tail -n +$((RETENTION_COUNT + 1)) | xargs -r rm --
  fi

  # Play success sound
  if [[ "$ENABLE_SUCCESS_SOUND" == "TRUE" ]]; then
    SOUND="$HOME/.local/share/koala-backup/sounds/game-over-winner.ogg"
    [[ -f "$SOUND" ]] && paplay "$SOUND"
  fi
else
  echo "❌ Backup failed."

  # Play failure sound
  if [[ "$ENABLE_FAILURE_SOUND" == "TRUE" ]]; then
    SOUND="$HOME/.local/share/koala-backup/sounds/game-over-loser.ogg"
    [[ -f "$SOUND" ]] && paplay "$SOUND"
  fi

  exit 1
fi
