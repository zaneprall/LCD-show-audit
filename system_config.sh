#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Gather system information
big_version=$(lsb_release -r | awk '{print $2}')
deb_version=$(tr -d '\n' < /etc/debian_version)
hardware_arch=$(getconf LONG_BIT)
hw_result=$(tr -d '\0' < /proc/device-tree/model)

# Determine hardware model
hardware_model=255
if [[ $hw_result == *"Raspberry Pi 5"* ]]; then
    hardware_model=5
fi

# Configure Wayland and handle symbolic links
raspi-config nonint do_wayland W1
if [ -f /boot/firmware/config.txt ]; then
    ln -sf /boot/firmware/config.txt /boot/config.txt
fi

# Select configuration file based on architecture and Debian version
config_base="./boot/config-normal"
if [ $hardware_arch -eq 32 ]; then
    config_version="10.9-32"
    [[ $(bc <<< "$deb_version < 10.9") -eq 1 ]] && config_version="10.9-32"
    [[ $(bc <<< "$deb_version >= 10.9 && $deb_version < 11.4") -eq 1 ]] && config_version="11.4-32"
    [[ $(bc <<< "$deb_version >= 12.1") -eq 1 ]] && config_version="12.1-32"
elif [ $hardware_arch -eq 64 ]; then
    config_version="11.4-64"
fi
cp -rf "${config_base}-${config_version}.txt" /boot/config.txt.bak

echo "Configuration set for Debian $deb_version on $hardware_arch-bit architecture."
