# -*- mode:sh; -*- vim:set ft=sh et sw=2 ts=2:
# package for tcp-wrappers

setup() {
  pkg_setup tcp-wrappers-7.6.q
}

config() {
  need_config .dummy || return 0

  make clean && touch .dummy
}

build() {
  make CC=$TARGET-gcc AR=$TARGET-ar RANLIB=$TARGET-ranlib linux
}

install() {

  need_install /usr/include/tcpd.h || return 0

  # lib items
  $DESTDIR_SUDO mkdir -p $DESTDIR/lib/
  $DESTDIR_SUDO cp -d shared/libwrap.so* $DESTDIR/lib/
  # dev items
  $DESTDIR_SUDO mkdir -p $DESTDIR/usr/include/
  $DESTDIR_SUDO cp tcpd.h $DESTDIR/usr/include/
  $DESTDIR_SUDO mkdir -p $DESTDIR/usr/lib/
  $DESTDIR_SUDO cp libwrap.a $DESTDIR/usr/lib/
}

publish() {
  pkg_publish usr/include usr/lib lib
}
