#!/bin/bash
#
# Ensure that symlinks are in place

set -e

SERVICE=SAMBA36
SAMBA_ADDON_HOME=/etc/frontview/samba/addons

backup_file() {
  file=$1
  [ ! -h $file ] || return 0
  # backup original smbd
  [ -f $file -a ! -f ${file}.orig ] && cp -a $file ${file}.orig || :
}

RESTART=

set_symlink() {
  src=$1 dest=$2
  if ! [ -h $dest -a "$(LANG=en_US.utf8 ls -dn $dest 2>/dev/null | awk '{ print $10 }')" = $src ]; then
    if [ -f $src ]; then
      rm -f $dest
      ln -s $src $dest
      RESTART=1
    fi
  fi
  return 0
}

backup_file /usr/sbin/smbd
backup_file /usr/sbin/nmbd

set_symlink /usr/local/sbin/smbd /usr/sbin/smbd
set_symlink /usr/local/sbin/nmbd /usr/sbin/nmbd

SMB2=$(grep "^${SERVICE}_SMB2=" /etc/default/services | sed "s/^${SERVICE}_SMB2=//")
[ -z "$SMB2" ] && SMB2=1 || :

if [ "$SMB2" = 1 -a -f "$SAMBA_ADDON_HOME/${SERVICE}.conf" ]; then
  if ! grep -qs "^include = $SAMBA_ADDON_HOME/${SERVICE}.conf" $SAMBA_ADDON_HOME/addons.conf; then
    echo "include = $SAMBA_ADDON_HOME/${SERVICE}.conf" >> $SAMBA_ADDON_HOME/addons.conf
    RESTART=1
  fi
else
  if grep -qs "^include = $SAMBA_ADDON_HOME/${SERVICE}.conf" $SAMBA_ADDON_HOME/addons.conf; then
    sed -i "/^include = ${SAMBA_ADDON_HOME//\//\/}\/${SERVICE}.conf/d" $SAMBA_ADDON_HOME/addons.conf
    RESTART=1
  fi
fi

# restart if changes
if [ -n "$RESTART" ]; then
  /etc/init.d/samba status &>/dev/null && /etc/init.d/samba restart || :
fi

exit 0
