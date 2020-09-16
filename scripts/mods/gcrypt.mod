# -*- mode:sh; -*- vim:set ft=sh et sw=2 ts=2:
# package for libgcrypt

setup() {
  pkg_setup libgcrypt11-1.4.5
}

config() {
  need_config config.h || return 0
  pkg_config --with-gpg-error-prefix=$SYSROOT/usr
}

build() {
  make
}

install() {
  need_install /usr/include/gcrypt.h || return 0

  $DESTDIR_SUDO make install DESTDIR=$DESTDIR

  [[ $PUBLISH_ALL ]] || {
    # post-install fixes
    echo "Removing libgcrypt.la to work around for broken cross-compilers"
    $DESTDIR_SUDO rm -f $DESTDIR/usr/lib/libgcrypt.la
  }
}

publish() {
  pkg_publish usr/include usr/lib usr/bin
}
