#!/bin/bash

# Ensure the script is run with sudo/root privileges
# if [ "$EUID" -ne 0 ]; then
#   echo "This script must be run with sudo or as root."
#   exit 1
# fi

grub-reboot "Windows"
reboot

