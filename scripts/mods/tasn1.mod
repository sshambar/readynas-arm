# -*- mode:sh; -*- vim:set ft=sh et sw=2 ts=2:
# package for libtasn1

setup() {
  pkg_setup libtasn1-3-2.7
}

config() {
  need_config config.h || return 0
  pkg_config
}

build() {
  make
}

install() {
  need_install /usr/include/libtasn1.h || return 0

  $DESTDIR_SUDO make install DESTDIR=$DESTDIR

  [[ $PUBLISH_ALL ]] || {
    # post-install fixes
    echo "Removing libtasn1.la to work around for broken cross-compilers"
    $DESTDIR_SUDO rm -f $DESTDIR/usr/lib/libtasn1.la
  }
}

publish() {
  pkg_publish
}
