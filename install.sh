#!/bin/bash

set -e
type=${1:-1000}

echo "Installing GSX-$type"

echo "Installing X11 config"
if [ ! -d /etc/X11/xorg.conf.d ]; then
  sudo mkdir -p /etc/X11/xorg.conf.d;
fi
  sudo cp usr/share/X11/xorg.conf.d/40-sennheiser-gsx-$type.conf /etc/X11/xorg.conf.d/

echo "Installing udev rule"
if [ -d /lib/udev/rules.d/ ]; then
  echo "Udev located in /lib"
  sudo cp lib/udev/rules.d/91-pulseaudio-gsx$type.rules /lib/udev/rules.d/
elif [ -d /etc/udev/rules.d/ ]; then
  echo "Udev located in /etc"
  sudo cp lib/udev/rules.d/91-pulseaudio-gsx$type.rules /etc/udev/rules.d/
else
  echo "Udev rules route not found, hence cancelling installation"
  echo "Expected locations: /etc/udev/rules.d/ OR /lib/udev/rules.d/"
fi

echo "Installing udev hwdb"
sudo cp etc/udev/hwdb.d/sennheiser-gsx.hwdb /etc/udev/hwdb.d/

echo "Installing pipewire profiles"
read -p "Install the channelswap-fix, see https://github.com/evilphish/sennheiser-gsx-1000/issues/9 (y for yes, n [default])? " -n 1 -r
echo 
if [[ $REPLY =~ ^[Yy]$ ]]
then
  sudo cp -r usr/share/alsa-card-profile/mixer/profile-sets/sennheiser-gsx-$type-channelswap.conf /usr/share/alsa-card-profile/mixer/profile-sets/
  echo "- installed channel-swap mix"
else
  sudo cp -r usr/share/alsa-card-profile/mixer/profile-sets/sennheiser-gsx-$type.conf /usr/share/alsa-card-profile/mixer/profile-sets/
  echo "- installed normal channel mix"
fi

echo "Reloading udev rules"
sudo systemd-hwdb update
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

