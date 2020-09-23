#!/bin/bash

SERVICE=SAMBA36
ADDON_HOME=/etc/frontview/addons
SAMBA_ADDON_HOME=/etc/frontview/samba/addons
PACKAGE=samba36-addon

CONF_FILES=""
PROG_FILES="/etc/frontview/apache/addons/${SERVICE}.conf* \
            $SAMBA_ADDON_HOME/${SERVICE}.conf \
            $ADDON_HOME/*/$SERVICE"

# Remove entries from services file
sed -i "/^${SERVICE}[_=]/d" /etc/default/services

# Stop service from running
eval `awk -F'!!' "/^${SERVICE}\!\!/ { print \\$5 }" $ADDON_HOME/addons.conf`

# Remove program files
if ! [ "$1" = "-upgrade" ]; then
  if [ "$CONF_FILES" != "" ]; then
    for i in $CONF_FILES; do
      rm -rf $i &>/dev/null
    done
  fi
  # dpkg remove will restore original binaries, restart server
  dpkg -r $PACKAGE >/dev/null
fi

if [ "$PROG_FILES" != "" ]; then
  for i in $PROG_FILES; do
    rm -rf $i
  done
fi

# Remove entry from addons.conf file
sed -i "/^${SERVICE}\!\!/d" $ADDON_HOME/addons.conf

if ! [ "$1" = "-upgrade" ]; then
  # Reread modified service configuration files
  killall -USR1 apache-ssl
fi

# Now remove ourself
rm -f $0

exit 0
