# -*- mode:sh; -*- vim:set ft=sh et sw=2 ts=2:
# package for libgpg-error

setup() {
  pkg_setup libgpg-error-1.6
}

config() {
  need_config config.h || return 0
  pkg_config
}

build() {
  make
}

install() {

  need_install /usr/include/gpg-error.h || return 0

  $DESTDIR_SUDO make install DESTDIR=$DESTDIR

  [[ $PUBLISH_ALL ]] || {
    # post-install fixes
    echo "Removing libgpg-error.la to work around for broken cross-compilers"
    $DESTDIR_SUDO rm -f $DESTDIR/usr/lib/libgpg-error.la
  }
}

publish() {
  pkg_publish usr/include usr/lib usr/bin
}
