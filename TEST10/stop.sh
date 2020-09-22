#!/bin/bash
#
# Remove symlinks

set -e

LOG=/tmp/test-addon.status

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

remove_symlink /usr/local/sbin/mytest /usr/sbin/mytest

# restart if changes
if [ -n "$RESTART" ]; then
  [ -n "$STOP" ] && ACTION=stop || ACTION=restart
  [ $ACTION = restart -a -f /usr/sbin/mytest ] && /usr/sbin/mytest || :
fi

echo "$(date): stop.sh: id=$(id -u) RESTART=$RESTART STOP=$STOP" >> "$LOG"

exit 0
