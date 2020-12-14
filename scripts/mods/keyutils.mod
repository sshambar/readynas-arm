# -*- mode:sh; -*- vim:set ft=sh et sw=2 ts=2:
# package for keyutils

setup() {
  pkg_setup keyutils-1.4
}

config() {
  need_config .dummy || return 0

  make clean && touch .dummy
}

build() {
  make CC=$TARGET-gcc AR=$TARGET-ar
}

install() {

  need_install /usr/include/keyutils.h || return 0

  $DESTDIR_SUDO make install DESTDIR=$DESTDIR
}

publish() {
  pkg_publish usr/include usr/lib lib
}
