# -*- mode:sh; -*- vim:set ft=sh et sw=2 ts=2:
# package for attr

setup() {
  pkg_setup attr-2.4.44
}

config() {
  need_config include/config.h || return 0
  pkg_config
}

build() {
  make
}

install() {

  need_install /usr/include/attr/xattr.h || return 0

  $DESTDIR_SUDO make install-lib DIST_ROOT=$DESTDIR
  $DESTDIR_SUDO make install-dev DIST_ROOT=$DESTDIR

  [[ $PUBLISH_ALL ]] || {
    echo "Removing libattr.la to work around for broken cross-compilers"
    $DESTDIR_SUDO rm -f $DESTDIR/usr/lib/libattr.*a
  }
}

publish() {
  pkg_publish
}
