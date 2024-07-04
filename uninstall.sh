#!/bin/bash

set -e
type=${1:-1000}

echo "Uninstalling GSX-$type"
echo "Deleting udev rules and config files ..."

sudo rm -f /usr/share/X11/xorg.conf.d/40-sensheiser-gsx-$type.conf
sudo rm -f /usr/share/alsa-card-profile/mixer/profile-sets/sennheiser-gsx-$type.conf
sudo rm -f /usr/share/alsa-card-profile/mixer/profile-sets/sennheiser-gsx-$type-channelswap.conf
sudo rm -f /etc/X11/xorg.conf.d/40-sensheiser-gsx-$type.conf
sudo rm -f /etc/udev/hwdb.d/sennheiser-gsx.hwdb
sudo rm -f /etc/udev/rules.d/91-pulseaudio-gsx$type.rules
sudo rm -f /lib/udev/rules.d/91-pulseaudio-gsx$type.rules

echo "Reloading udev rules ..."
sudo udevadm control -R
sudo udevadm trigger

read -p "Restart all Pipewire services now (y for yes, n [default])? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo "Restarting wireplumber, pipewire, and pipewire-pulse ..."
  systemctl --user restart wireplumber pipewire pipewire-pulse
  sleep 2
  echo "Pipewire sould be started now."
else
  echo "Skipped restarting. You can do this yourself by running:"
  echo "systemctl --user restart wireplumber pipewire pipewire-pulse"
fi
