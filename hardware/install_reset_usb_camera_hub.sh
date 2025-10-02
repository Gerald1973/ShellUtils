#!/bin/bash

# Installation script for reset_usb_camera_hub.sh and reset_usb_camera_hub.service
# Copies local files without recreating if they already exist
# Run from the directory containing the source files

# Check if run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root (use sudo)." 1>&2
   exit 1
fi

# Copy the script reset_usb_camera_hub.sh only if it does not exist
if [ ! -f /usr/local/bin/reset_usb_camera_hub.sh ]; then
    cp reset_usb_camera_hub.sh /usr/local/bin/reset_usb_camera_hub.sh
    chmod +x /usr/local/bin/reset_usb_camera_hub.sh
    echo "Script /usr/local/bin/reset_usb_camera_hub.sh copied and made executable."
else
    echo "Script /usr/local/bin/reset_usb_camera_hub.sh already exists. Skipping copy."
fi

# Copy the systemd service file only if it does not exist
SERVICE_DEST="/etc/systemd/system/reset_usb_camera_hub.service"
if [ ! -f "$SERVICE_DEST" ]; then
    cp systemd/reset_usb_camera_hub.service "$SERVICE_DEST"
    # Reload systemd and enable the service
    systemctl daemon-reload
    systemctl enable reset_usb_camera_hub.service
    echo "Service $SERVICE_DEST copied, systemd reloaded, and service enabled."
else
    echo "Service $SERVICE_DEST already exists. Skipping copy."
    # Reload systemd if the service exists (in case modified)
    systemctl daemon-reload
    if ! systemctl is-enabled reset_usb_camera_hub.service >/dev/null 2>&1; then
        systemctl enable reset_usb_camera_hub.service
        echo "Service enabled."
    else
        echo "Service already enabled."
    fi
fi

echo "Installation complete. Reboot to test on RYZEN5."