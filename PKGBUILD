#Maintainer: Amelia Carter <ameliamarycarter@gmail.com>
_pkgname=status-string-maker
pkgname=$_pkgname-git
pkgver=1.0
pkgrel=1
pkgdesc="Lightweight program for setting dwm's status bar."
arch=('x86_64')
url="https://github.com/kohotli/status-string-maker/"
license=('GPL3')
depends=('racket' 'iproute2' 'xorg-xsetroot')
optdepends=('mpc: Display the currently-playing song.' 'acpi: Display the current battery status and level.')
provides=("$_pkgname")
conflicts=("$_pkgname")
source=('git+https://github.com/kohotli/status-string-maker')
md5sums=('SKIP')

build() {
	cd "$srcdir/$_pkgname"
	make
}

package() {
	cd "$srcdir/$_pkgname"
	make install
}
