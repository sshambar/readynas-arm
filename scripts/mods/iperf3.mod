# -*- mode:sh; -*- vim:set ft=sh et sw=2 ts=2:
# module for iperf3

setup() {
  pkg_setup iperf-3.7
}

config() {
  need_config Makefile || return 0
  pkg_config --prefix=/usr/local ac_cv_header_endian_h=no
}

build() {
  make
}

install() {
  need_install /usr/local/include/iperf_api.h || return 0

  $DESTDIR_SUDO make install DESTDIR=$DESTDIR
}

publish() {
  pkg_publish usr/local/lib usr/local/include
}
