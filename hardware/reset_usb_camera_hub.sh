#!/bin/bash

VID="1a40"
PID="0101"

# Trouver le chemin sysfs (ex. : 5-4) en scannant /sys/bus/usb/devices/
DEVICE_PATH=""
for d in /sys/bus/usb/devices/*; do
  if [ -f "$d/idVendor" ] && [ "$(cat "$d/idVendor")" = "$VID" ] && [ -f "$d/idProduct" ] && [ "$(cat "$d/idProduct")" = "$PID" ]; then
    DEVICE_PATH="${d##*/}"
    break
  fi
done

if [ -z "$DEVICE_PATH" ]; then
  echo "Hub USB $VID:$PID non trouvé."
  exit 1
fi

echo "Reset du hub USB $VID:$PID au chemin $DEVICE_PATH..."

# Unbind (détacher)
echo "$DEVICE_PATH" | sudo tee /sys/bus/usb/drivers/usb/unbind > /dev/null

# Attendre 2s pour simuler un cycle
sleep 2

# Bind (réattacher)
echo "$DEVICE_PATH" | sudo tee /sys/bus/usb/drivers/usb/bind > /dev/null

echo "Reset terminé. Vérifiez dmesg et arecord -l."