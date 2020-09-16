# -*- mode:sh; -*- vim:set ft=sh et sw=2 ts=2:
# package for PAM

setup() {
  pkg_setup pam-1.1.1
}

config() {
  need_config config.h || return 0
  pkg_config
}

build() {
  # generated files... create bogus ones
  pushd doc/specs
  touch parse_l.o parse_y.o
  touch padout draft-morgan-pam.raw
  touch draft-morgan-pam-current.txt
  popd

  make
}

install() {
  need_install /usr/include/security/pam_client.h || return 0

  $DESTDIR_SUDO make install DESTDIR=$DESTDIR
}

publish() {
  pkg_publish usr/include lib
}
