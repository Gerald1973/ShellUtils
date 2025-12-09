#!/bin/bash

# Check for root privileges (Required for exhaustive BIOS info)
if [ "$EUID" -ne 0 ]; then
  echo "Attention : Veuillez lancer ce script avec sudo pour voir les infos complètes du BIOS."
  echo "Usage : sudo $0"
  echo ""
  # We continue anyway, but some commands might fail or show less info
fi

# Clear the screen for better readability
clear

echo "================================================================="
echo "                System Information (Exhaustive)"
echo "================================================================="

# Operating System Information
echo ""
echo "--- Operating System ---"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "OS: $PRETTY_NAME"
fi
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Hostname: $(hostname)"
echo ""

# BIOS & Motherboard Information (EXHAUSTIVE)
echo "--- BIOS & Firmware (DMI Type 0) ---"
if command -v dmidecode &> /dev/null; then
    # Type 0 contains BIOS information (Vendor, Version, Release Date, ROM Size, Characteristics)
    dmidecode -t 0 | grep -v "SMBIOS" | grep -v "Handle" | grep -v "DMI type"
else
    echo "Outil 'dmidecode' introuvable ou accès refusé."
fi
echo ""

echo "--- System Information (DMI Type 1) ---"
if command -v dmidecode &> /dev/null; then
    # Type 1 contains System UUID, Serial Number, Manufacturer
    dmidecode -t 1 | grep -v "SMBIOS" | grep -v "Handle" | grep -v "DMI type"
else
    echo "Données non disponibles."
fi
echo ""

echo "--- Baseboard Information (DMI Type 2) ---"
if command -v dmidecode &> /dev/null; then
    # Type 2 contains Motherboard specific info
    dmidecode -t 2 | grep -v "SMBIOS" | grep -v "Handle" | grep -v "DMI type"
else
    echo "Données non disponibles."
fi
echo ""

# CPU Information
echo "--- CPU ---"
echo "Model: $(lscpu | grep "Model name" | cut -d ':' -f 2 | sed 's/^[ \t]*//')"
echo "Cores: $(nproc)"
echo "Architecture: $(lscpu | grep "Architecture" | cut -d ':' -f 2 | sed 's/^[ \t]*//')"
# Adding generic CPU flags/features which are often relevant to BIOS settings (Virtualization etc)
echo "Virtualization (VT-x/AMD-V): $(lscpu | grep "Virtualization" | cut -d ':' -f 2 | sed 's/^[ \t]*//')"
echo ""

# Graphics Card (GPU) Information
echo "--- Graphics Card ---"
lspci | grep -E "VGA|3D"
echo ""

# Memory Information
echo "--- Memory ---"
free -h
echo "--- Memory Hardware Details (DMI Type 17 - Short) ---"
if command -v dmidecode &> /dev/null; then
    # Shows speed and type of installed sticks (often controlled by BIOS XMP)
    dmidecode -t 17 | grep -E "Size:|Type:|Speed:|Manufacturer:|Part Number:" | grep -v "No Module Installed"
fi
echo ""

# Disk Usage Information
echo "--- Disk Usage ---"
df -h
echo ""

# Block Device Information
echo "--- Block Devices ---"
lsblk
echo ""

# Network Information
echo "--- Network ---"
echo "IP Address(es): $(hostname -I)"
echo "Network Interface Configuration:"
ip -br addr
echo ""

# Service information
echo "--- Service list ---"
systemctl list-units --type=service
echo ""

# fstab
echo "--- fstab ---"
cat /etc/fstab
echo ""

# startup files
echo "--- systemd startup files ---"
ls -lR /etc/systemd/system/
echo ""

#Startup files order
echo "--- sysyemd files order ---"
systemd-analyze critical-chain
echo ""

#Startup log
echo "--- boot log ---"
journalctl -b
echo ""

echo "--- config.txt (Only for Raspberry) ---"
cat /boot/firmware/config.txt
echo ""

echo "================================================================="
echo "                  Scan Complete"
echo "================================================================="
