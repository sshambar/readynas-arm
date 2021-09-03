# -*- mode:sh; -*- vim:set ft=sh et sw=2 ts=2:
# package for Bind 9

setup() {
  pkg_setup bind9-9.7.3.dfsg
  echo "Required libraries/headers in SYSROOT: $SYSROOT"
  echo "  (installing these are left as an exercise for the reader :)"
  echo
}

config() {
  need_config config.h || return 0

  pkg_config --prefix=/usr/local --enable-epoll --without-openssl --with-randomdev=/dev/urandom BUILD_CC=gcc
}

build() {
  make
}

install() {
  need_install /usr/local/bin/dig || return 0

  $DESTDIR_SUDO make install DESTDIR=$DESTDIR
}

publish() {
  pkg_publish usr/local/include usr/local/lib usr/local/bin
}
