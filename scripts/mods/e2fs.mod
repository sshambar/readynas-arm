# -*- mode:sh; -*- vim:set ft=sh et sw=2 ts=2:
# package for e2fsprogs

setup() {
  pkg_setup e2fsprogs-1.41.12
}

config() {
  need_config Makefile || return 0
  pkg_config --enable-elf-shlibs
}

build() {
  make
}

install() {
  need_install /usr/include/et/com_err.h || return 0

  $DESTDIR_SUDO make install-libs DESTDIR=$DESTDIR
  [[ $PUBLISH_ALL ]] && $DESTDIR_SUDO make install DESTDIR=$DESTDIR || :

  # add missing symlink
  $DESTDIR_SUDO ln -s et/com_err.h $DESTDIR/usr/include/
}

publish() {
  pkg_publish usr/include usr/lib usr/bin usr/share/et
}
