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

# Execution privileges
if [ "$EUID" -eq 0 ] && [ -n "${SUDO_USER}" ]; then
    echo "Run with sudo: yes (invoked by ${SUDO_USER})"
elif [ "$EUID" -eq 0 ]; then
    echo "Run with sudo: no (logged in directly as root)"
else
    echo "Run with sudo: no (user ${USER}, some information will be missing)"
fi

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

# Open Ports
echo "--- Listening Ports (TCP/UDP) ---"
if command -v ss &> /dev/null; then
    if [ "$EUID" -ne 0 ]; then
        echo "(Run with sudo to see the process owning each port)"
    fi
    ss -tulpn
else
    echo "ss not found."
fi
echo ""

# Firewall
echo "--- Firewall ---"
if command -v ufw &> /dev/null; then
    echo "# ufw"
    ufw status verbose 2>&1
    echo ""
fi
if command -v nft &> /dev/null; then
    echo "# nftables"
    nft list ruleset 2>&1
    echo ""
fi
if command -v iptables &> /dev/null; then
    echo "# iptables"
    iptables -S 2>&1
    echo ""
fi
if command -v firewall-cmd &> /dev/null; then
    echo "# firewalld"
    firewall-cmd --list-all 2>&1
    echo ""
fi
if ! command -v ufw &> /dev/null && ! command -v nft &> /dev/null \
    && ! command -v iptables &> /dev/null && ! command -v firewall-cmd &> /dev/null; then
    echo "No firewall tool found (ufw, nft, iptables, firewall-cmd)."
fi
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
echo "--- systemd files order ---"
systemd-analyze critical-chain
echo ""

# #Startup log
# echo "--- boot log ---"
# journalctl -b -p warning
# echo ""

echo "--- config.txt (Only for Raspberry) ---"
cat /boot/firmware/config.txt
echo ""

# Cron
echo "--- Cron: /etc/crontab ---"
if [ -f /etc/crontab ]; then
    cat /etc/crontab
else
    echo "/etc/crontab not found."
fi
echo ""

echo "--- Cron: /etc/cron.d ---"
if [ -d /etc/cron.d ]; then
    for f in /etc/cron.d/*; do
        [ -f "${f}" ] || continue
        echo "# ${f}"
        cat "${f}"
        echo ""
    done
else
    echo "/etc/cron.d not found."
fi

echo "--- Cron: periodic directories ---"
for d in /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly; do
    if [ -d "${d}" ]; then
        echo "# ${d}"
        ls -l "${d}"
    fi
done
echo ""

echo "--- Cron: user crontabs ---"
if [ "$EUID" -eq 0 ]; then
    for u in $(cut -d ':' -f 1 /etc/passwd); do
        entries=$(crontab -l -u "${u}" 2>/dev/null)
        if [ -n "${entries}" ]; then
            echo "# crontab of ${u}"
            echo "${entries}"
            echo ""
        fi
    done
else
    echo "# crontab of ${USER} (run with sudo to see all users)"
    crontab -l 2>/dev/null || echo "No crontab for ${USER}."
fi
echo ""

echo "--- systemd timers ---"
systemctl list-timers --all
echo ""

# VPN Configuration (secrets are masked)
echo "--- VPN: WireGuard ---"
if command -v wg &> /dev/null; then
    echo "wg show:"
    wg show 2>/dev/null || echo "No active WireGuard interface (or root privileges required)."
else
    echo "wg not found (wireguard-tools not installed)."
fi
if [ -d /etc/wireguard ]; then
    for f in /etc/wireguard/*.conf; do
        [ -f "${f}" ] || continue
        echo "# ${f}"
        sed -E 's/^([[:space:]]*(PrivateKey|PresharedKey)[[:space:]]*=).*/\1 <hidden>/I' "${f}"
        echo ""
    done
else
    echo "/etc/wireguard not found or not readable."
fi
echo ""

echo "--- VPN: OpenVPN ---"
if [ -d /etc/openvpn ]; then
    for f in $(find /etc/openvpn -type f \( -name "*.conf" -o -name "*.ovpn" \) 2>/dev/null); do
        echo "# ${f}"
        # Hide inline private keys and static keys
        sed -E '/^<(key|tls-auth|tls-crypt|secret)>/,/^<\/(key|tls-auth|tls-crypt|secret)>/c\<hidden>' "${f}"
        echo ""
    done
else
    echo "/etc/openvpn not found."
fi
echo ""

echo "--- VPN: NetworkManager connections ---"
if command -v nmcli &> /dev/null; then
    nmcli -t -f NAME,TYPE,DEVICE connection show | grep -iE "vpn|wireguard"
    echo ""
else
    echo "nmcli not found."
fi

echo "--- VPN: network interfaces (tun/tap/wg) ---"
ip -br link show type wireguard 2>/dev/null
ip -br addr | grep -E "^(tun|tap|wg)"
echo ""

echo "================================================================="
echo "                  Scan Complete"
echo "================================================================="
