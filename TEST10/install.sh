#!/bin/bash

LOG=/tmp/test-addon.status

ADDON_HOME=/etc/frontview/addons
PACKAGE=test-addon

cleanup() {
  cd /
  rm -rf $orig_dir
  rm -f /tmp/${PACKAGE}.deb

  # Reread modified service configuration files
  killall -USR1 apache-ssl
}

bye() {
  cleanup
  . /frontview/bin/functions
  # clean up partial install
  if [ -n "$name" -a -f "$ADDON_HOME/${name}.remove" ]; then
    sh $ADDON_HOME/${name}.remove &>/dev/null
  fi
  echo -n ": $1 "
  log_status "$1" 1
  echo "$(date): install.sh $version: failed" >> "$LOG"

  exit 1
}

orig_dir=`pwd`
name=`awk -F'!!' '{ print $1 }' addons.conf`
stop=`awk -F'!!' '{ print $5 }' addons.conf`
run=`awk -F'!!' '{ print $4 }' addons.conf`
version=`awk -F'!!' '{ print $3 }' addons.conf`

echo "$(date): install.sh $version: id=$(id -u) started" >> "$LOG"
chmod a+w "$LOG"

[ -z "$name" ] && bye "ERROR: No addon name!"

# check for previous ENABLED setting
ENABLED=$(grep "^${name}=" /etc/default/services | sed "s/^${name}=//")
[ -z "$ENABLED" ] && ENABLED=1
ENABLED_F1=$(grep "^${name}_FEATURE1=" /etc/default/services | sed "s/^${name}_FEATURE1=//")
[ -z "$ENABLED_F1" ] && ENABLED_F1=1

# Remove old versions of our addon
if [ -f "$ADDON_HOME/${name}.remove" ]; then
  sh $ADDON_HOME/${name}.remove -upgrade &>/dev/null
fi

# Copy our removal script to the default directory
cp $orig_dir/remove.sh $ADDON_HOME/${name}.remove

# Extract program files
cd / || bye "ERROR: Could not change working directory."
tar --no-overwrite-dir -xzf $orig_dir/files.tgz || bye "ERROR: Could not extract files properly."

# Add ourself to the main addons.conf file
[ -d $ADDON_HOME ] || mkdir $ADDON_HOME
grep -sv "^${name}\!\!" $ADDON_HOME/addons.conf >/tmp/addons.conf$$
cat $orig_dir/addons.conf >>/tmp/addons.conf$$ || bye "ERROR: Could not include addon configuration."
cp /tmp/addons.conf$$ $ADDON_HOME/addons.conf || bye "ERROR: Could not update addon configuration."
rm -f /tmp/addons.conf$$ || bye "ERROR: Could not clean up."
chown -R admin.admin $ADDON_HOME

# Add ourself to the services file
grep -v "^${name}[_=]" /etc/default/services >/tmp/services$$ || bye "ERROR: Could not back up service configuration."
echo "${name}_FEATURE1=$ENABLED_F1" >>/tmp/services$$ || bye "ERROR: Could not add service configuration."
echo "${name}=$ENABLED" >>/tmp/services$$ || bye "ERROR: Could not add service configuration."
cp /tmp/services$$ /etc/default/services || bye "ERROR: Could not update service configuration."
rm -f /tmp/services$$ || bye "ERROR: Could not clean up."


###########  Addon specific action go here ###########

# prevent symlink/restart on package install
DISABLE_ACTIVATION=1 dpkg -i /tmp/${PACKAGE}.deb >/dev/null || bye "ERROR: unable to install $PACKAGE"
[ -d /var/cache/apt/archives ] && cp /tmp/${PACKAGE}.deb /var/cache/apt/archives/

######################################################

[ "$ENABLED" = 1 ] && eval $run || eval $stop

friendly_name=`awk -F'!!' '{ print $2 }' $orig_dir/addons.conf`

# Remove the installation files
cleanup

# allow apache to settle
sleep 3

echo "$(date): install.sh: done" >> "$LOG"

exit 0
