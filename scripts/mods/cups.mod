# -*- mode:sh; -*- vim:set ft=sh et sw=2 ts=2:
# package for Cups

setup() {
  pkg_setup cupsys-1.1.14
}

config() {
  need_config Makedefs || return 0

  CONFIG_ARGS=
  # if not installing as root, change cups user/group to allow install
  destdir_owner_is_root || CONFIG_ARGS="--with-cups-user=$(id -u -n) --with-cups-group=$(id -g -n)"

  rm -f config.cache
  # work around ancient configure script that doesn't correctly prefix
  # tools, and forces strip with native install
  CC=$TARGET-gcc CXX=$TARGET-g++ AR=$CROSSDIR/$TARGET-ar RANLIB=$CROSSDIR/$TARGET-ranlib INSTALL="`pwd`/install-sh -c" pkg_config $CONFIG_ARGS
}

build() {
  # handle generated file
  if [ ! -f pstoraster/genarch.o ]; then
    # genarch on mv5sft generates this file, other targets may differ
    [ $TARGET = arm-mv5sft-linux-gnueabi ] || \
      fail "Run pstoraster/genarch to create pstoraster/arch.h on target $TARGET"
    touch pstoraster/genarch.o
    touch pstoraster/genarch
    cat - > pstoraster/arch.h <<"EOF"
/* Parameters derived from machine and compiler architecture */

	 /* ---------------- Scalar alignments ---------------- */

#define arch_align_short_mod 2
#define arch_align_int_mod 4
#define arch_align_long_mod 4
#define arch_align_ptr_mod 4
#define arch_align_float_mod 4
#define arch_align_double_mod 8

	 /* ---------------- Scalar sizes ---------------- */

#define arch_log2_sizeof_short 1
#define arch_log2_sizeof_int 2
#define arch_log2_sizeof_long 2
#define arch_sizeof_ptr 4
#define arch_sizeof_float 4
#define arch_sizeof_double 8

	 /* ---------------- Unsigned max values ---------------- */

#define arch_max_uchar ((unsigned char)0xff + (unsigned char)0)
#define arch_max_ushort ((unsigned short)0xffff + (unsigned short)0)
#define arch_max_uint ((unsigned int)0xffffffff + (unsigned int)0)
#define arch_max_ulong ((unsigned long)0xffffffffL + (unsigned long)0)

	 /* ---------------- Miscellaneous ---------------- */

#define arch_is_big_endian 0
#define arch_ptrs_are_signed 0
#define arch_floats_are_IEEE 1
#define arch_arith_rshift 2
#define arch_can_shift_full_long 1
EOF
  fi

  make
}

install() {
  need_install /usr/include/cups/cups.h || return 0

  $DESTDIR_SUDO make install BUILDROOT=$DESTDIR STRIPPROG=
}

publish() {
  pkg_publish usr/include usr/lib usr/bin/cups-config
}
