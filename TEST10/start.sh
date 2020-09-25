#!/bin/bash
#
# Ensure that symlinks are in place

set -e

LOG=/tmp/test-addon.status

SERVICE=TEST10

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

backup_file /usr/sbin/mytest

set_symlink /usr/local/sbin/mytest /usr/sbin/mytest

FEATURE1=$(grep "^${SERVICE}_FEATURE1=" /etc/default/services | sed "s/^${SERVICE}_FEATURE1=//")

# restart if changes
if [ -n "$RESTART" ]; then
  /usr/sbin/mytest
fi

echo "$(date): start.sh: id=$(id -u) RESTART=$RESTART FEATURE1=$FEATURE1" >> "$LOG"

exit 0
