# -*- mode:sh; -*- vim:set ft=sh et sw=2 ts=2:
# package for OpenLDAP

setup() {
  pkg_setup openldap-2.4.23
}

config() {
  need_config Makefile || return 0

  pkg_config --with-subdir=/ldap --disable-slapd CC=$TARGET-gcc AR=$TARGET-ar --with-yielding-select ac_cv_func_memcmp_working=yes
}

build() {
  make
}

install() {
  need_install /usr/include/ldap.h || return 0

  $DESTDIR_SUDO make install DESTDIR=$DESTDIR STRIP=
}

publish() {
  pkg_publish
}
