#!/bin/bash -ex

# Is CUPSPASSWORD set? If not, set to $CUPSADMIN
if [ -z "$CUPSPASSWORD" ]; then
    CUPSPASSWORD=$CUPSADMIN
fi

if [ $(grep -ci $CUPSADMIN /etc/shadow) -eq 0 ]; then
    adduser --system --no-create-home --ingroup lpadmin $CUPSADMIN
fi

# add password
echo $CUPSADMIN:$CUPSPASSWORD | chpasswd

# add tzdata
ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata


mkdir -p /run/dbus
rm -rf /run/dbus/pid
rm -rf /run/avahi-daemon/pid

dbus-daemon --system
/usr/sbin/avahi-daemon --no-chroot &


./printer-setup.sh &
# Start CUPS in foreground
exec /usr/sbin/cupsd -f
