# -*- mode:sh; -*- vim:set ft=sh et sw=2 ts=2:
# package for Samba 3

setup() {
  pkg_setup samba-3.6.25/source3

  echo "Required libraries/headers in SYSROOT: $SYSROOT"
  echo "  libcom_err.so.2 and compile_et (from e2fsprogs)"
  echo "  libattr, libacl, libgpg-error, libgcrypt11, libtasn1, gnutls26"
  echo "  cupsys, krb5, cyrus-sasl2, openldap"
  echo "  (installing these are left as an exercise for the reader :)"
  echo
  echo "Install can be installed in /usr/local, just replace binaries"
  echo " /usr/sbin/smbd and /usr/sbin/nmbd and the rest should just work"
  echo
}

config() {
  need_config include/config.h || return 0

  if grep -q -- "LINUX_LFS_SUPPORT=cross" configure; then

    # patch things we can't workaround with config.cache
    patch -p1 <<"EOF"
--- a/configure	2015-02-22 06:16:23.000000000 -0800
+++ b/configure	2020-09-14 16:42:18.000000000 -0700
@@ -8643,7 +8643,7 @@
         old_CPPFLAGS="$CPPFLAGS"
         CPPFLAGS="-D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE $CPPFLAGS"
        if test "$cross_compiling" = yes; then :
-  LINUX_LFS_SUPPORT=cross
+  LINUX_LFS_SUPPORT=yes
 else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
@@ -13289,7 +13289,7 @@
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $libreplace_cv_HAVE_GETADDRINFO" >&5
 $as_echo "$libreplace_cv_HAVE_GETADDRINFO" >&6; }
 
-if test x"$libreplace_cv_HAVE_GETADDRINFO" = x"yes"; then
+if test x"$libreplace_cv_HAVE_GETADDRINFO" = xx"yes"; then
 	# getaddrinfo is broken on some AIX systems
 	# see bug 5910, use our replacements if we detect
 	# a broken system.
EOF
  fi

  # create config.cache with all our cross-compile overrides
  rm -f config.cache
  cat - > config.cache <<EOF
ac_cv_path_CUPS_CONFIG=${SYSROOT}/usr/bin/cups-config
MODULE_idmap_ad=SHARED
MODULE_idmap_adex=SHARED
MODULE_idmap_hash=SHARED
MODULE_idmap_rid=SHARED
MODULE_auth_netlogond=SHARED
samba_cv_CC_NEGATIVE_ENUM_VALUES=yes
ac_cv_file__proc_sys_kernel_core_pattern=yes
ac_cv_func_ext_krb5_enctype_to_string=yes
ac_cv_func_memcmp_working=yes
libreplace_cv_HAVE_MMAP=yes
libreplace_cv_HAVE_SECURE_MKSTEMP=yes
libreplace_cv_HAVE_C99_VSNPRINTF=yes
libreplace_cv_STRPTIME_OK=yes
libreplace_cv_READDIR_NEEDED=no
libreplace_cv_REPLACE_INET_NTOA=no
libreplace_cv_HAVE_GETADDRINFO=yes
libreplace_cv_HAVE_IFACE_GETIFADDRS=yes
samba_cv_have_setresuid=yes
samba_cv_have_setresgid=yes
ac_cv_file__proc_sys_kernel_core_pattern=yes
samba_cv_linux_getgrouplist_ok=yes
samba_cv_have_longlong=yes
samba_cv_SIZEOF_TIME_T=no
samba_cv_TIME_T_MAX=no
samba_cv_SIZEOF_OFF_T=yes
samba_cv_HAVE_OFF64_T=no
samba_cv_SIZEOF_INO_T=yes
samba_cv_HAVE_INO64_T=no
samba_cv_SIZEOF_DEV_T=yes
samba_cv_HAVE_DEV64_T=no
samba_cv_HAVE_DEVICE_MAJOR_FN=yes
samba_cv_HAVE_DEVICE_MINOR_FN=yes
samba_cv_HAVE_MAKEDEV=yes
samba_cv_HAVE_UNSIGNED_CHAR=yes
samba_cv_HAVE_BROKEN_READDIR_NAME=no
samba_cv_HAVE_KERNEL_OPLOCKS_LINUX=yes
samba_cv_HAVE_KERNEL_CHANGE_NOTIFY=yes
samba_cv_HAVE_KERNEL_SHARE_MODES=yes
samba_cv_HAVE_FTRUNCATE_EXTEND=yes
samba_cv_HAVE_BROKEN_GETGROUPS=no
samba_cv_USE_SETREUID=yes
samba_cv_HAVE_FCNTL_LOCK=yes
samba_cv_HAVE_BROKEN_FCNTL64_LOCKS=no
samba_cv_HAVE_STRUCT_FLOCK64=yes
samba_cv_REALPATH_TAKES_NULL=yes
samba_cv_HAVE_WRFILE_KEYTAB=yes
smb_krb5_cv_enctype_to_string_takes_krb5_context_arg=no
smb_krb5_cv_enctype_to_string_takes_size_t_arg=yes
fu_cv_sys_stat_statvfs64=yes
samba_cv_HAVE_BROKEN_READLINK=no
vfsfileid_cv_statfs=yes
EOF
  # don't allow it to be overwritten by configure
  chmod a-w config.cache

  # now configure with our cache and options
  pkg_config -C CFLAGS=-Os --prefix=/usr/local --with-fhs --libdir=/usr/local/lib --with-modulesdir=/usr/local/lib/samba --with-lockdir=/var/run/samba --with-logfilebase=/var/log/samba --with-nmbdsocketdir=/var/run/samba --with-ncalrpcdir=/var/run/samba --with-statedir=/var/lib/samba --with-cachedir=/var/cache/samba --with-piddir=/var/run/samba --with-swatdir=/usr/local/share/samba/swat --with-privatedir=/etc/samba --with-krb5=${SYSROOT}/usr --with-automount
}

build() {
  make
}

install() {
  need_install /usr/local/include/tevent.h || return 0

  $DESTDIR_SUDO make install DESTDIR=$DESTDIR
}

publish() {
  pkg_publish usr/local
}
