#!/bin/bash
[[ -x /usr/share/koala/koala-init.sh ]] && /usr/share/koala/koala-init.sh

CONFIG_FILE="$HOME/.config/koala/config.conf"
BACKUP_SCRIPT="$HOME/usr/share/koala/system-backup.sh"
LOG_DIR="$HOME/.local/share/koala/logs"

# Ensure config exists
[[ -f "$CONFIG_FILE" ]] || {
  dialog --msgbox "Missing config file: $CONFIG_FILE" 7 50
  exit 1
}

source "$CONFIG_FILE"

main_menu() {
  while true; do
    CHOICE=$(dialog --clear --backtitle "Koala Utility" \
      --title "Main Menu" \
      --menu "Choose an option:" 16 50 9 \
      1 "Run Backup Now" \
      2 "Edit Config (Manual)" \
      3 "View Latest Log" \
      4 "Toggle Success Sound ($ENABLE_SUCCESS_SOUND)" \
      5 "Toggle Failure Sound ($ENABLE_FAILURE_SOUND)" \
      6 "Set Retention Count ($RETENTION_COUNT)" \
      7 "Set Backup Source ($BACKUP_SOURCE)" \
      8 "Set Backup Destination ($BACKUP_DEST)" \
      9 "Restore Backup" \
      9 "Exit" \
      3>&1 1>&2 2>&3)

    case "$CHOICE" in
      1) run_backup ;;
      2) edit_config ;;
      3) view_logs ;;
      4) toggle_setting "ENABLE_SUCCESS_SOUND" ;;
      5) toggle_setting "ENABLE_FAILURE_SOUND" ;;
      6) set_retention ;;
      7) set_path "BACKUP_SOURCE" ;;
      8) set_path "BACKUP_DEST" ;;
      9) restore_backup ;;     
      10) clear; exit 0 ;;
    esac
  done
}

run_backup() {
  (
    "$BACKUP_SCRIPT" &
    PID=$!

    i=0
    sp='|/-\'
    while kill -0 $PID 2>/dev/null; do
      i=$(( (i+1) %4 ))
      printf "\r[%c] Running backup..." "${sp:$i:1}"
      sleep 0.1
    done
    wait $PID
    STATUS=$?
    echo ""  # newline after spinner
    exit $STATUS
  ) | dialog --title "Backup in Progress" --programbox 10 60

  if [[ $? -eq 0 ]]; then
    dialog --msgbox "✅ Backup completed successfully." 7 50
  else
    dialog --msgbox "❌ Backup failed. Check logs for details." 7 50
  fi
}

edit_config() {
  ${EDITOR:-nano} "$CONFIG_FILE"
  source "$CONFIG_FILE"
}

view_logs() {
  mkdir -p "$LOG_DIR"
  LOG_FILE=$(ls -1t "$LOG_DIR"/*.log 2>/dev/null | head -n1)

  if [[ -z "$LOG_FILE" ]]; then
    dialog --msgbox "No logs found." 6 40
  else
    dialog --textbox "$LOG_FILE" 20 70
  fi
}

toggle_setting() {
  local VAR=$1
  local NEW_VAL
  if [[ "${!VAR}" == "TRUE" ]]; then
    NEW_VAL="FALSE"
  else
    NEW_VAL="TRUE"
  fi
  sed -i "s/^$VAR=.*/$VAR=\"$NEW_VAL\"/" "$CONFIG_FILE"
  source "$CONFIG_FILE"
}

set_retention() {
  local NEW_VAL
  NEW_VAL=$(dialog --inputbox "Enter number of backups to keep:" 8 50 "$RETENTION_COUNT" 3>&1 1>&2 2>&3)
  if [[ "$NEW_VAL" =~ ^[0-9]+$ ]]; then
    sed -i "s/^RETENTION_COUNT=.*/RETENTION_COUNT=\"$NEW_VAL\"/" "$CONFIG_FILE"
    source "$CONFIG_FILE"
  else
    dialog --msgbox "Invalid number." 6 40
  fi
}

set_path() {
  local VAR=$1
  local CURRENT="${!VAR}"
  local NEW_PATH
  NEW_PATH=$(dialog --inputbox "Enter new path for $VAR:" 8 60 "$CURRENT" 3>&1 1>&2 2>&3)
  if [[ -n "$NEW_PATH" ]]; then
    sed -i "s|^$VAR=.*|$VAR=\"$NEW_PATH\"|" "$CONFIG_FILE"
    source "$CONFIG_FILE"
  fi
}

main_menu



restore_backup() {
  local backups=("${BACKUP_DEST:-$HOME/Desktop/Koala-Backups}"/backup_*.tar.gz)
  if [[ ${#backups[@]} -eq 0 ]]; then
    dialog --msgbox "No backups found in $BACKUP_DEST." 7 50
    return
  fi

  local choices=()
  for b in "${backups[@]}"; do
    choices+=("$(basename "$b")" "")
  done

  local selection
  selection=$(dialog --title "Restore Backup" --menu "Select a backup to restore:" 15 60 6 "${choices[@]}" 3>&1 1>&2 2>&3) || return

  local archive="${BACKUP_DEST:-$HOME/Desktop/Koala-Backups}/$selection"
  local default_restore="$HOME/Koala-Restores/${selection%.tar.gz}"
  local target
  target=$(dialog --inputbox "Enter directory to restore into (new or empty only):" 8 60 "$default_restore" 3>&1 1>&2 2>&3) || return

  # Safety: Don't allow restore to root or system folders
  if [[ "$target" == "/" || "$target" == "/home" || "$target" == "/etc"* || "$target" == "/usr"* ]]; then
    dialog --msgbox "❌ Unsafe restore location. Choose a user folder." 7 50
    return
  fi

  mkdir -p "$target"

  if [ "$(ls -A "$target")" ]; then
    dialog --yesno "⚠️ Target directory is not empty. Proceed and overwrite its contents?" 8 60 || return
  fi

  if tar -xzf "$archive" -C "$target"; then
    dialog --msgbox "✅ Backup restored to $target" 7 50
  else
    dialog --msgbox "❌ Restore failed." 7 50
  fi
}
