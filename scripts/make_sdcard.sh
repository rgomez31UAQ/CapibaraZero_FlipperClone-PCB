#!/bin/sh

# Copyright (C) 2024 Andrea Canale

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

echo "Welcome to CapibaraZero SD maker!"

if [ "$(id -u)" -ne 0 ]
  then echo Please run this script as root or using sudo!
  exit
fi

DEVICE=$1
SCRIPT_DIR=$(pwd)

read -r -p "This script will destroy all the data in your device $DEVICE. Continue (y/n)?" choice

case "$choice" in 
  y|Y ) ;;
  n|N ) exit 255;;
  * ) echo "Invalid choice" && exit 255;;
esac

echo "Removing all partitions..."

# Remove all partitions
wipefs -a "$DEVICE"

echo "Creating partition table and partitions..."

# Create partition table(GPT) and partition
parted "$DEVICE" mklabel gpt --script
parted "$DEVICE" mkpart primary 0% 100% --script

echo "Formatting partition to FAT32..."

# Format FAT32 partition
mkfs -t vfat "$DEVICE"1

echo "Mounting new partition..."

# Mount partition
mount "$DEVICE"1 /mnt

echo "Creating SD structure and example files..."

# Create sd structure
cd /mnt || exit 255

mkdir captive_portal
mkdir dhcp_glutton

# Example config
echo '{
	"ssid": "ExampleSSID",
	"password": "MySecretPassword"
}' > dhcp_glutton/config.json

echo '{
	"ssid": "ExampleSSID",
	"password": "MySecretPassword"
}' > captive_portal/config.json

mkdir arp_poisoner

echo '{
    "ssid": "ExampleSSID",
    "password": "ExamplePassword",
    "target_mac": [255,255,255,255,255,255],
    "target_ip": [192, 168, 1, 1]
}' > arp_poisoner/config.json

mkdir NFC
# Example NFC config
echo "FFFFFFFFFFFF
B4C132439EEF
7BBEBOC8FB49
1BC1F6FF32CC
D9D923DAE083
990AEB52D8AC
90DEAB425EA5
40A061DABC43
43D65DC2363C
5AFE558BC710" > NFC/keys.txt

mkdir subghz
mkdir subghz/raw_capture
# Example config
echo '{
  "frequency_analyzer": {
    "lora": false
  },
  "raw_record": {
    "frequency": 433.92,
    "bandwidth": 150.50,
    "deviation": 47.60,
    "modulation": 0,
    "rssi_threshold": -90
  }
}' > subghz/config.json

mkdir ducky
# Example payload
echo "REM My first payload
DELAY 3000
STRING Hello, World!
ENTER" > ducky/example.txt

mkdir wifi
mkdir bluetooth
mkdir IR
mkdir -p IR/signals
mkdir -p IR/signal_rc

# Return to directory where the script live
cd "$SCRIPT_DIR" || exit 255

# Unmount device
umount /mnt