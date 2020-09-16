# -*- mode:sh; -*- vim:set ft=sh et sw=2 ts=2:
# package for Cyrus SASL

setup() {
  pkg_setup cyrus-sasl2-2.1.23.dfsg1
}

config() {
  need_config config.h || return 0
  pkg_config
}

build() {
  # handle generated file
  if [ ! -f include/makemd5.o ]; then
    # makemd5 run on mv5sft generates same file as source
    [ $TARGET = arm-mv5sft-linux-gnueabi ] || \
      fail "Run include/makemd5 to create include/md5global.h on target $TARGET"
    touch include/makemd5.o
    touch include/makemd5
    touch include/md5global.h
  fi

  make
}

install() {
  need_install /usr/include/sasl/sasl.h || return 0

  make install DESTDIR=$DESTDIR
}

publish() {
  pkg_publish
}
