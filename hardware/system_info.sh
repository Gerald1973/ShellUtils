#!/bin/bash

# Clear the screen for better readability
clear

echo "================================================================="
echo "                System Information"
echo "================================================================="

# Operating System Information
echo ""
echo "--- Operating System ---"
if [ -f /etc/os-release ]; then
    # Use the os-release file to get the distribution name
    . /etc/os-release
    echo "OS: $PRETTY_NAME"
fi
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Hostname: $(hostname)"
echo ""

# CPU Information
echo "--- CPU ---"
# Display CPU model, core count, and architecture
echo "Model: $(lscpu | grep "Model name" | cut -d ':' -f 2 | sed 's/^[ \t]*//')"
echo "Cores: $(nproc)"
echo "Architecture: $(lscpu | grep "Architecture" | cut -d ':' -f 2 | sed 's/^[ \t]*//')"
echo ""

# Graphics Card (GPU) Information
echo "--- Graphics Card ---"
# Use lspci to find VGA compatible controllers (graphics cards)
lspci | grep -E "VGA|3D"
echo ""

# Memory Information
echo "--- Memory ---"
# Display RAM and swap usage in a human-readable format
free -h
echo ""

# Disk Usage Information
echo "--- Disk Usage ---"
# Display disk space usage for all mounted filesystems
df -h
echo ""

# Block Device Information
echo "--- Block Devices ---"
# List block devices (disks and partitions), their sizes, and mount points
lsblk
echo ""

# Network Information
echo "--- Network ---"
# Display the machine's IP addresses
echo "IP Address(es): $(hostname -I)"
echo "Network Interface Configuration:"
# Display a summary of network interfaces
ip -br addr
echo ""

echo "================================================================="
echo "                  Scan Complete"
echo "================================================================="