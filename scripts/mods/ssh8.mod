# -*- mode:sh; -*- vim:set ft=sh et sw=2 ts=2:
# package for OpenSSH 8

setup() {
  pkg_setup openssh-8.4p1

  echo "Required libraries/headers in SYSROOT: $SYSROOT"
  echo "  libcom_err.so.2 and compile_et (from e2fsprogs)"
  echo "  tcp-wrappers, keyutils, krb5"
  echo "  (installing these are left as an exercise for the reader :)"
  echo
  echo "Install can be installed in /usr/local, just replace binaries"
  echo " /usr/sbin/sshd and the rest should just work"
  echo
}

config() {
  need_config config.h || return 0

  pkg_config -C --prefix=/usr/local --with-pam --with-selinux --with-kerberos5
}

build() {
  make
}

install() {
  need_install /usr/local/sbin/sshd || return 0

  $DESTDIR_SUDO make install DESTDIR=$DESTDIR
}

publish() {
  pkg_publish usr/local
}
