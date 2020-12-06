#!/bin/bash
#
# Remove symlinks

set -e

SERVICE=SAMBA36
SAMBA_ADDON_HOME=/etc/frontview/samba/addons

RESTART=
STOP=

remove_symlink() {
  src=$1 dest=$2
  # restore original binaries if symlinks present...
  if [ -h $dest -a "$(LANG=en_US.utf8 ls -dn $dest 2>/dev/null | awk '{ print $10 }')" = $src ]; then
    rm -f $dest
    # restore original (if available)
    [ -f ${dest}.orig ] && cp -a ${dest}.orig $dest || STOP=1
    RESTART=1
  fi
  return 0
}

ENABLED=$(grep "^${SERVICE}=" /etc/default/services | sed "s/^${SERVICE}=//")
[ -z "$ENABLED" ] && ENABLED=0 || :

# only remove symlink/SMB2 if we're disabled
if ! [ "$ENABLED" = 1 ]; then

  remove_symlink /usr/local/sbin/smbd /usr/sbin/smbd
  remove_symlink /usr/local/sbin/nmbd /usr/sbin/nmbd
  remove_symlink /usr/local/sbin/winbindd /usr/sbin/winbindd

  if grep -qs "^include = $SAMBA_ADDON_HOME/${SERVICE}.conf" $SAMBA_ADDON_HOME/addons.conf; then
    sed -i "/^include = ${SAMBA_ADDON_HOME//\//\/}\/${SERVICE}.conf/d" $SAMBA_ADDON_HOME/addons.conf
    RESTART=1
  fi
fi

# restart if changes
if [ -n "$RESTART" ]; then
  [ -n "$STOP" ] && ACTION=stop || ACTION=restart
  /etc/init.d/samba status &>/dev/null && /etc/init.d/samba $ACTION || :
fi

exit 0
