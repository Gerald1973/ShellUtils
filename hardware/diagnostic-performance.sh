#!/bin/bash

# ============================================================
# Diagnostic performances - Ryzen 5 / Debian 13 Trixie
# Aucun paramètre système n'est modifié.
# ============================================================

set -u

echo
echo "============================================================"
echo " DIAGNOSTIC PERFORMANCES - $(hostname)"
echo "============================================================"
echo

echo "=== OS / KERNEL ==="
cat /etc/os-release | grep -E '^(PRETTY_NAME|VERSION)='
uname -a

echo
echo "=== CPUFREQ ==="

if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver ]; then
    echo "Driver     : $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver)"
fi

if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
    echo "Governor   : $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
fi

if command -v powerprofilesctl >/dev/null 2>&1; then
    echo "Power profile:"
    powerprofilesctl get
fi

if command -v cpupower >/dev/null 2>&1; then
    echo
    cpupower frequency-info 2>/dev/null | head -35
else
    echo "cpupower : non installé"
fi

echo
echo "=== CPU ==="
lscpu | grep -E \
'Model name|CPU\(s\)|Core|Thread|MHz|NUMA|Architecture'

echo
echo "=== RAM ==="

if command -v dmidecode >/dev/null 2>&1; then
    sudo dmidecode -t memory 2>/dev/null |
        grep -E 'Size:|Speed:|Configured Memory Speed:|Part Number:'
else
    echo "dmidecode : non installé"
fi

echo
echo "=== RAM UTILISATION ==="
free -h

echo
echo "=== NVME / STOCKAGE ==="
lsblk -d -o NAME,MODEL,SIZE,ROTA,SCHED

echo
echo "--- Scheduler NVMe ---"

for d in /sys/block/nvme*; do
    if [ -d "$d" ]; then
        echo "[$d]"
        cat "$d/queue/scheduler"
    fi
done

echo
echo "=== RESEAU ==="
ip -br addr

echo
echo "--- NetworkManager ---"
if command -v nmcli >/dev/null 2>&1; then
    nmcli device status
fi

echo
echo "--- Ethernet enp5s0 ---"
if command -v ethtool >/dev/null 2>&1; then
    ethtool enp5s0 2>/dev/null |
        grep -E 'Speed:|Duplex:|Link detected:'
else
    echo "ethtool : non installé"
fi

echo
echo "=== NFS ==="
findmnt -t nfs,nfs4 \
    -o TARGET,SOURCE,FSTYPE,OPTIONS

echo
echo "=== SWAP ==="
swapon --show
echo
free -h

echo
echo "=== VM / MEMOIRE ==="
sysctl \
    vm.swappiness \
    vm.vfs_cache_pressure \
    vm.overcommit_memory \
    vm.zone_reclaim_mode \
    vm.nr_hugepages

echo
echo "=== CPU GOVERNOR SERVICE ==="

if systemctl cat set-cpu-governor.service >/dev/null 2>&1; then
    systemctl cat set-cpu-governor.service
else
    echo "set-cpu-governor.service : absent"
fi

echo
echo "=== SERVICES PERFORMANCE ==="

for service in \
    set-cpu-governor \
    preload \
    power-profiles-daemon \
    NetworkManager-wait-online \
    docker \
    containerd
do
    printf "%-35s : " "$service"

    if systemctl is-active --quiet "$service"; then
        echo "ACTIVE"
    elif systemctl is-enabled --quiet "$service" 2>/dev/null; then
        echo "ENABLED / INACTIVE"
    else
        echo "INACTIF / ABSENT"
    fi
done

echo
echo "=== KERNEL CMDLINE ==="
cat /proc/cmdline

echo
echo "=== AMD PSTATE ==="

if [ -d /sys/devices/system/cpu/amd_pstate ]; then
    echo "amd_pstate présent"

    for f in \
        status \
        prefcore
    do
        if [ -f "/sys/devices/system/cpu/amd_pstate/$f" ]; then
            echo "$f : $(cat "/sys/devices/system/cpu/amd_pstate/$f")"
        fi
    done
else
    echo "Répertoire amd_pstate non trouvé"
fi

echo
echo "=== GPU NVIDIA ==="

if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi \
        --query-gpu=name,driver_version,pstate,temperature.gpu,power.draw,utilization.gpu,memory.used,memory.total \
        --format=csv
else
    echo "nvidia-smi : non disponible"
fi

echo
echo "=== PCIe ASPM ==="
dmesg 2>/dev/null | grep -iE 'ASPM|PCIe' | tail -20

echo
echo "=== DISQUES / ESPACE ==="
df -hT

echo
echo "============================================================"
echo " FIN DU DIAGNOSTIC"
echo "============================================================"
echo
