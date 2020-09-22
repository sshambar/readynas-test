#!/bin/bash

LOG=/tmp/test-addon.status

SERVICE=TEST10
ADDON_HOME=/etc/frontview/addons
PACKAGE=test-addon

CONF_FILES=""
PROG_FILES="/etc/frontview/apache/addons/${SERVICE}.conf* \
            $ADDON_HOME/*/$SERVICE"

echo "$(date): remove.sh: id=$(id -u) started" >> "$LOG"
chmod a+w "$LOG"

# Stop service from running
eval `awk -F'!!' "/^${SERVICE}\!\!/ { print \\$5 }" $ADDON_HOME/addons.conf`

# Remove program files
if ! [ "$1" = "-upgrade" ]; then
  if [ "$CONF_FILES" != "" ]; then
    for i in $CONF_FILES; do
      rm -rf $i &>/dev/null
    done
  fi
  echo "$(date): remove.sh: removing $PACKAGE (not upgrade)" >> "$LOG"
  # dpkg remove will restore original binaries, restart server
  dpkg -r $PACKAGE
fi

if [ "$PROG_FILES" != "" ]; then
  for i in $PROG_FILES; do
    rm -rf $i
  done
fi

# Remove entries from services file
sed -i "/^${SERVICE}[_=]/d" /etc/default/services

# Remove entry from addons.conf file
sed -i "/^${SERVICE}\!\!/d" $ADDON_HOME/addons.conf

if ! [ "$1" = "-upgrade" ]; then
  # Reread modified service configuration files
  killall -USR1 apache-ssl
fi

# Now remove ourself
rm -f $0

echo "$(date): remove.sh: done" >> "$LOG"

exit 0
