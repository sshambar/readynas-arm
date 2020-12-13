# -*- mode:sh; -*- vim:set ft=sh et sw=2 ts=2:
# package for libselinux

setup() {
  pkg_setup libselinux-2.0.96
}

config() {
  need_config .dummy || return 0
  if grep -q 'includedir=@includedir@' src/libselinux.pc.in; then
    echo "Patch src/libselinux.pc.in for cross compiling"
    patch -p1 <<"EOF"
--- a/src/libselinux.pc.in	2010-06-14 13:33:29.000000000 -0700
+++ b/src/libselinux.pc.in.new	2020-12-13 01:26:58.000000000 -0800
@@ -1,7 +1,7 @@
 prefix=@prefix@
-exec_prefix=${prefix}
+exec_prefix=
 libdir=${exec_prefix}/@libdir@
-includedir=@includedir@
+includedir=/usr/include
 
 Name: libselinux
 Description: SELinux utility library
EOF
  fi
  if grep -q '^TLSFLAGS += ' src/Makefile; then
    echo "Patch src/Makefile for cross compiling"
    patch -p1 <<"EOF"
--- a/src/Makefile	2011-10-20 18:48:30.000000000 -0700
+++ b/src/Makefile	2020-12-13 01:35:00.000000000 -0800
@@ -52,7 +52,7 @@
 
 ARCH := $(patsubst i%86,i386,$(shell uname -m))
 ifneq (,$(filter i386,$(ARCH)))
-TLSFLAGS += -mno-tls-direct-seg-refs
+#TLSFLAGS += -mno-tls-direct-seg-refs
 endif
 
 ifeq (,$(strip $(LIBSEPOLDIR)))
EOF
  fi
  touch .dummy
  make clean
}

build() {
  CC=$TARGET-gcc AR=$TARGET-ar RANLIB=$TARGET-ranlib INCLUDEDIR=$SYSROOT/usr/include LDLIBS=-L$SYSROOT/usr/lib make
}

install() {

  need_install /usr/include/selinux.h || return 0

  $DESTDIR_SUDO make install DESTDIR=$DESTDIR
}

publish() {
  pkg_publish usr/include usr/lib lib
}
