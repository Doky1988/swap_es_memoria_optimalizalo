#!/bin/bash
# -----------------------------------------------------------
# Swap és Memória Optimalizáló script – webszerverekhez
# Swap méret RAM alapján táblázat szerint
#
# Ez a script létrehozza: Swap fájlt, optimalizálja a
# memóriahasználatot, és néhány alap rendszerparamétert is
# finomhangol a stabilitás és teljesítmény érdekében.
#
# Dátum: 2025.10.19
# Készítette: Doky
# -----------------------------------------------------------

set -e

echo "🔧 Webszerver-optimalizálás indul..."

# --- RAM lekérdezés (GB-ban, pontosan) ---
TOTAL_RAM=$(awk '/MemTotal/ {printf "%.1f\n", $2/1024/1024}' /proc/meminfo)
RAM_INT=${TOTAL_RAM%.*}

# --- Swap méret meghatározása táblázat alapján ---
if   [ "$RAM_INT" -le 1 ];  then SWAP_SIZE=1
elif [ "$RAM_INT" -le 2 ];  then SWAP_SIZE=1
elif [ "$RAM_INT" -le 4 ];  then SWAP_SIZE=2
elif [ "$RAM_INT" -le 8 ];  then SWAP_SIZE=2
elif [ "$RAM_INT" -le 16 ]; then SWAP_SIZE=4
elif [ "$RAM_INT" -le 32 ]; then SWAP_SIZE=4
else SWAP_SIZE=8
fi

echo "💾 Teljes RAM: ${TOTAL_RAM}GB → Swap méret: ${SWAP_SIZE}GB"

# --- SWAP létrehozása ---
if [ -f /swapfile ]; then
  echo "⚠️  Swapfile már létezik, kihagyva a létrehozást."
else
  echo "📦 Swapfile létrehozása ${SWAP_SIZE}GB méretben..."
  sudo fallocate -l ${SWAP_SIZE}G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab > /dev/null
fi

# --- SYSCTL finomhangolás ---
echo "🧠 Rendszerparaméterek optimalizálása..."
sudo tee -a /etc/sysctl.conf > /dev/null <<'EOF'

# --- Optimalizált rendszerbeállítások VPS-hez ---
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_background_ratio=5
vm.dirty_ratio=10

# TCP kapcsolat-kezelés és hálózati finomhangolás
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_keepalive_time=300
net.ipv4.tcp_tw_reuse=1
net.ipv4.ip_local_port_range=1024 65000
net.ipv4.tcp_max_syn_backlog=4096
net.core.somaxconn=4096
EOF

# --- Új beállítások betöltése ---
sudo sysctl -p > /dev/null

echo ""
echo "✅ Optimalizálás kész!"
echo
echo "📊 Ellenőrzés:"
free -h
echo
echo "⚙️ Aktuális beállítások:"
sudo sysctl vm.swappiness
sudo sysctl vm.vfs_cache_pressure
echo ""