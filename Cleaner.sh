#!/bin/bash

# Format tanggal dan waktu
DATE_NOW=$(date "+%Y-%m-%d %H:%M:%S")

# Warna untuk tampilan yang lebih estetik
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

# Log file di direktori TmuxManager
LOG_FILE="/home/hg680p/TmuxManager/Cleaner.log"

# Header
echo -e "${GREEN}====================================" | tee -a "$LOG_FILE"
echo -e "${YELLOW}  Pembersihan & Optimasi Sistem - $DATE_NOW" | tee -a "$LOG_FILE"
echo -e "${GREEN}====================================" | tee -a "$LOG_FILE"

# 1. Periksa apakah sedang dalam sesi tmux
if [[ -n "$TMUX" ]]; then
    echo -e "${RED}[WARNING] Script ini tidak boleh dijalankan dalam sesi tmux!" | tee -a "$LOG_FILE"
    exit 1
fi

# 2. Hentikan layanan logging sementara (Kecuali tmux)
echo -e "${YELLOW}[INFO] Menghentikan layanan logging..." | tee -a "$LOG_FILE"
sudo systemctl stop rsyslog
sudo systemctl stop systemd-journald

# 3. Hapus log dan file lama, tetapi jangan sentuh file yang sedang digunakan
echo -e "${YELLOW}[INFO] Menghapus log lama dan membersihkan /var/log..." | tee -a "$LOG_FILE"
sudo journalctl --vacuum-time=1d
sudo find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;
sudo rm -rf /var/log/*.gz /var/log/*.old

# 4. Hapus cache dan file sementara
echo -e "${YELLOW}[INFO] Menghapus cache APT dan file sementara..." | tee -a "$LOG_FILE"
sudo apt-get autoremove -y
sudo apt-get clean -y
sudo rm -rf /tmp/* /var/tmp/*

# 5. Optimasi Swap dan Memori
echo -e "${YELLOW}[INFO] Mengoptimalkan memori dan swap..." | tee -a "$LOG_FILE"
sudo sync && sudo sysctl -w vm.drop_caches=3
sudo swapoff /dev/zram0
echo 536870912 | sudo tee /sys/block/zram0/disksize
sudo mkswap /dev/zram0
sudo swapon /dev/zram0

# 6. Hapus cache thumbnail
echo -e "${YELLOW}[INFO] Menghapus cache thumbnail..." | tee -a "$LOG_FILE"
rm -rf ~/.cache/thumbnails/*

# 7. Restart layanan log
echo -e "${YELLOW}[INFO] Mengaktifkan kembali layanan logging..." | tee -a "$LOG_FILE"
sudo systemctl start rsyslog
sudo systemctl start systemd-journald

# 8. Matikan layanan tidak penting
echo -e "${YELLOW}[INFO] Mematikan layanan yang tidak diperlukan..." | tee -a "$LOG_FILE"
sudo systemctl stop bluetooth.service
sudo systemctl disable bluetooth.service

# 9. Menampilkan status setelah pembersihan
echo -e "${GREEN}====================================" | tee -a "$LOG_FILE"
echo -e "${YELLOW}Pembersihan & Optimasi Selesai!" | tee -a "$LOG_FILE"
echo -e "${GREEN}====================================" | tee -a "$LOG_FILE"

df -h | tee -a "$LOG_FILE"
free -h | tee -a "$LOG_FILE"
uptime | tee -a "$LOG_FILE"

# Footer
echo -e "${GREEN}====================================" | tee -a "$LOG_FILE"
