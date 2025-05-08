pkgname=koala
pkgver=1.0.0
pkgrel=1
pkgdesc="Set-and-forget terminal-based backup app with scheduler, TUI, and sound notifications"
arch=('any')
url="https://github.com/lostqeb/koala"
license=('MIT')
depends=('bash' 'dialog' 'tar' 'xdg-utils' 'systemd')
install=koala.install
source=(
  'system-backup.sh'
  'koala-ui.sh'
  'koala-init.sh'
  'config.conf'
  'koala-package.sh'
  'verify-koala-package.sh'
  'system-backup.service'
  'system-backup.timer'
  'koala_icon.png'
  'koala.desktop'
  'error.ogg'
  'interuption.ogg'
  'notif.ogg'
  'success.ogg'
)
md5sums=('SKIP' 'SKIP' 'SKIP' 'SKIP' 'SKIP' 'SKIP' 'SKIP' 'SKIP'
         'SKIP' 'SKIP' 'SKIP' 'SKIP' 'SKIP' 'SKIP')

package() {
  install -Dm755 "$srcdir/system-backup.sh" "$pkgdir/usr/share/koala/system-backup.sh"
  install -Dm755 "$srcdir/koala-ui.sh" "$pkgdir/usr/share/koala/koala-ui.sh"
  install -Dm755 "$srcdir/koala-init.sh" "$pkgdir/usr/share/koala/koala-init.sh"
  install -Dm644 "$srcdir/config.conf" "$pkgdir/usr/share/koala/config.conf"
  install -Dm755 "$srcdir/koala-package.sh" "$pkgdir/usr/share/koala/koala-package.sh"
  install -Dm755 "$srcdir/verify-koala-package.sh" "$pkgdir/usr/share/koala/verify-koala-package.sh"
  install -Dm644 "$srcdir/system-backup.service" "$pkgdir/usr/lib/systemd/user/system-backup.service"
  install -Dm644 "$srcdir/system-backup.timer" "$pkgdir/usr/lib/systemd/user/system-backup.timer"
  install -Dm644 "$srcdir/koala_icon.png" "$pkgdir/usr/share/icons/hicolor/128x128/apps/koala.png"
  install -Dm644 "$srcdir/koala.desktop" "$pkgdir/usr/share/applications/koala.desktop"
  install -Dm644 "$srcdir/error.ogg" "$pkgdir/usr/share/koala/sounds/error.ogg"
  install -Dm644 "$srcdir/interuption.ogg" "$pkgdir/usr/share/koala/sounds/interuption.ogg"
  install -Dm644 "$srcdir/notif.ogg" "$pkgdir/usr/share/koala/sounds/notif.ogg"
  install -Dm644 "$srcdir/success.ogg" "$pkgdir/usr/share/koala/sounds/success.ogg"

  install -d "$pkgdir/usr/bin"
  ln -s /usr/share/koala/system-backup.sh "$pkgdir/usr/bin/koala-backup"
  ln -s /usr/share/koala/koala-ui.sh "$pkgdir/usr/bin/koala-ui"
}
