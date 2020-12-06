#!/bin/bash
#
# This script returns 0 if symlinks present, 1 otherwise
#

HAS_SYMLINK=

check_symlink() {
  src=$1 dest=$2
  if [ -h $dest -a "$(LANG=en_US.utf8 ls -dn $dest 2>/dev/null | awk '{ print $10 }')" = $src ]; then
    HAS_SYMLINK=1
  fi
  return 0
}

check_symlink /usr/local/sbin/smbd /usr/sbin/smbd
check_symlink /usr/local/sbin/nmbd /usr/sbin/nmbd
check_symlink /usr/local/sbin/winbindd /usr/sbin/winbindd

[ -z "$HAS_SYMLINK" ] && exit 1

exit 0
