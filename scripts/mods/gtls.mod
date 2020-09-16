# -*- mode:sh; -*- vim:set ft=sh et sw=2 ts=2:
# package for gnutls

setup() {
  pkg_setup gnutls26-2.8.6
}

config() {
  need_config config.h || return 0
  pkg_config --with-libgcrypt-prefix=$SYSROOT/usr --with-libtasn1-prefix=$SYSROOT/usr
}

build() {
  make
}

install() {
  need_install /usr/include/gnutls/crypto.h || return 0

  $DESTDIR_SUDO make install DESTDIR=$DESTDIR
}

publish() {
  pkg_publish
}
