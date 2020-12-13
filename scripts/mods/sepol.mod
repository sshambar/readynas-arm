# -*- mode:sh; -*- vim:set ft=sh et sw=2 ts=2:
# package for libsepol

setup() {
  pkg_setup libsepol-2.0.41
}

config() {
  need_config .dummy || return 0
  if grep -q 'includedir=@includedir@' src/libsepol.pc.in; then
    echo "Patch src/libsepol.pc.in for cross compiling"
    patch -p1 <<"EOF"
--- a/src/libsepol.pc.in	2010-03-24 12:40:05.000000000 -0700
+++ b/src/libsepol.pc.in	2020-12-13 00:46:11.000000000 -0800
@@ -1,7 +1,7 @@
 prefix=@prefix@
-exec_prefix=${prefix}
+exec_prefix=
 libdir=${exec_prefix}/@libdir@
-includedir=@includedir@
+includedir=/usr/include
 
 Name: libsepol
 Description: SELinux policy library
EOF
  fi
  touch .dummy
  make clean
}

build() {
  CC=$TARGET-gcc AR=$TARGET-ar RANLIB=$TARGET-ranlib INCLUDEDIR=$SYSROOT/usr/include make
}

install() {

  need_install /usr/include/sepol/sepol.h || return 0

  $DESTDIR_SUDO make install DESTDIR=$DESTDIR
}

publish() {
  pkg_publish usr/include usr/lib lib
}
