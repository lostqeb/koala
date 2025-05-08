# 🐨 Koala Backup

**Koala** is a simple, set-and-forget terminal-based backup tool for Linux.  
It provides an easy-to-use text UI, automated backup scheduling via systemd, and support for sound notifications and restores — all while keeping user configuration safely in `~/.config/koala/`.

---

## ✨ Features

- Terminal UI (`koala-ui`) for easy configuration and backup control
- Scheduled backups using systemd timers
- Restore backups from within the UI
- Retention policy management (automatically delete old backups)
- Sound notifications for success and failure
- System-wide install, but user-specific config
- Works without root after install

---

## 🚀 Installation

### From AUR (recommended):
```bash
yay -S koala
```

### From GitHub:
```bash
git clone https://github.com/yourusername/koala.git
cd koala
./install-local.sh
```

---

## 🧰 Usage

### Launch the UI:
```bash
koala-ui
```

### Run a manual backup:
```bash
koala-backup
```

### View or modify your config:
```bash
nano ~/.config/koala/config.conf
```

Your config includes:
```ini
BACKUP_SOURCE="$HOME/Documents"
BACKUP_DEST="$HOME/Desktop/Koala-Backups"
RETENTION_COUNT="5"
ENABLE_SUCCESS_SOUND="TRUE"
ENABLE_FAILURE_SOUND="TRUE"
```

---

## 🔁 Automatic Backups

Koala enables a `systemd --user` timer after install.

Check status:
```bash
systemctl --user status system-backup.timer
```

Run it now:
```bash
systemctl --user start system-backup.service
```

---

## 📦 Uninstallation

### AUR:
```bash
sudo pacman -Rns koala
```

### Manual:
Just delete the Koala folder from `~/.local/share/koala` and `~/.config/koala/`.

---

## 🧠 Tip

Your configuration is safe in `~/.config/koala/config.conf`, so system updates won't overwrite your settings.

---

## 📄 License

MIT © 2025 Alex
