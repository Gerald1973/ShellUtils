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
echo "--- Graphics Card & Drivers ---"
# Hardware listing with kernel driver info
lspci -nnk | grep -i -A3 -E "VGA|3D|Display"
echo ""

echo "--- NVIDIA Driver & CUDA ---"
if command -v nvidia-smi &> /dev/null; then
    echo "NVIDIA-SMI Status:"
    nvidia-smi
else
    echo "nvidia-smi not found (No NVIDIA driver active)."
fi
echo ""

if command -v nvcc &> /dev/null; then
    echo "CUDA Compiler (nvcc):"
    nvcc --version
else
    echo "nvcc not found (CUDA Toolkit not in PATH)."
fi

if [ -f /proc/driver/nvidia/version ]; then
    echo "Kernel Module Version:"
    cat /proc/driver/nvidia/version
fi
echo ""

# Display Server Information
echo "--- Display Server ---"
if [ -n "$XDG_SESSION_TYPE" ]; then
    echo "Session Type: $XDG_SESSION_TYPE"
else
    # Try to detect via loginctl for the sudo user
    TARGET_USER="${SUDO_USER:-$USER}"
    if command -v loginctl &> /dev/null; then
        SESSION_ID=$(loginctl list-sessions | grep "$TARGET_USER" | awk '{print $1}' | head -n 1)
        if [ -n "$SESSION_ID" ]; then
            SESSION_TYPE=$(loginctl show-session "$SESSION_ID" -p Type)
            echo "Session Type (loginctl): ${SESSION_TYPE#Type=}"
        else
            echo "No active session found for user $TARGET_USER"
        fi
    else
        echo "Could not detect session type."
    fi
fi
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

# Kernel Parameters
echo "--- Kernel Parameters (sysctl) ---"
if command -v sysctl &> /dev/null; then
    sysctl -a 2>/dev/null
else
    echo "sysctl command not found."
fi
echo ""

# Service information
echo "--- Service list ---"
systemctl list-units --type=service
echo ""

# Library Information
echo "--- Libraries (Versions) ---"
if command -v dpkg &> /dev/null; then
    dpkg -l | grep "^ii  lib" | awk '{print $2, $3}'
elif command -v rpm &> /dev/null; then
    rpm -qa | grep "^lib"
elif command -v pacman &> /dev/null; then
    pacman -Q | grep "^lib"
else
    echo "Package manager not found. Cannot list libraries."
fi
echo ""

# fstab
echo "--- fstab ---"
cat /etc/fstab
echo ""

# GRUB Configuration
echo "--- GRUB Configuration (/etc/default/grub) ---"
if [ -f /etc/default/grub ]; then
    cat /etc/default/grub
else
    echo "/etc/default/grub not found."
fi
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
