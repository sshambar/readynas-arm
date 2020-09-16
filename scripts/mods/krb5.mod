# -*- mode:sh; -*- vim:set ft=sh et sw=2 ts=2:
# package for krb5

setup() {
  pkg_setup krb5-1.8.3+dfsg/src
}

config() {
  need_config include/autoconf.h || return 0

  if grep -q 'COMPILE_ET-sys= compile_et' config/pre.in; then

    echo "Patch config/pre.in with compile_et -> @compile_et@"
    echo "  and hardcode path to mk_cmds"
    patch -p1 <<EOF
--- a/config/pre.in	2010-09-19 11:31:21.000000000 -0700
+++ b/config/pre.in	2020-09-05 00:18:22.000000000 -0700
@@ -407,7 +407,7 @@
 #
 ### /* these are invoked as \$(...) foo.et, which works, but could be better */
 COMPILE_ET= \$(COMPILE_ET-@COM_ERR_VERSION@)
-COMPILE_ET-sys= compile_et
+COMPILE_ET-sys= @compile_et@
 COMPILE_ET-k5= \$(BUILDTOP)/util/et/compile_et -d \$(top_srcdir)/util/et
 
 .SUFFIXES:  .h .c .et .ct
@@ -447,7 +447,7 @@
 # ss command table rules
 #
 MAKE_COMMANDS= \$(MAKE_COMMANDS-@SS_VERSION@)
-MAKE_COMMANDS-sys= mk_cmds
+MAKE_COMMANDS-sys= ${SYSROOT}/usr/bin/mk_cmds
 MAKE_COMMANDS-k5= \$(BUILDTOP)/util/ss/mk_cmds
 
 .ct.c:
EOF
  fi

  # create config.cache with our cross-compile presets
  rm -f config.cache
  cat - > config.cache <<EOF
krb5_cv_attr_constructor_destructor=yes,yes
ac_cv_func_regcomp=yes
ac_cv_printf_positional=yes
ac_cv_prog_compile_et=$SYSROOT/usr/bin/compile_et
krb5_cv_compile_et_useful=yes
EOF
  # don't allow it to be overwritten by configure
  chmod a-w config.cache

  pkg_config -C --with-system-et --with-system-ss
}

build() {
  make
}

install() {
  need_install /usr/include/krb5.h || return 0

  $DESTDIR_SUDO make install DESTDIR=$DESTDIR
  $DESTDIR_SUDO make install-headers DESTDIR=$DESTDIR
}

publish() {
  pkg_publish usr/include usr/lib usr/bin/krb5-config
}
