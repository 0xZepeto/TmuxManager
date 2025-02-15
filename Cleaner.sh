#!/bin/bash

# Format tanggal dan waktu
DATE_NOW=$(date "+%Y-%m-%d %H:%M:%S")

# Warna untuk tampilan yang lebih estetik
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

# Lokasi log
LOG_DIR="/home/hg680p/TmuxManager"
LOG_FILE="$LOG_DIR/Cleaner.log"

# Buat folder log jika belum ada
mkdir -p "$LOG_DIR"

# Header
echo -e "${GREEN}====================================" | tee -a "$LOG_FILE"
echo -e "${YELLOW}  Pembersihan & Optimasi Sistem - $DATE_NOW" | tee -a "$LOG_FILE"
echo -e "${GREEN}====================================" | tee -a "$LOG_FILE"

# 1. Pastikan script tidak berjalan dalam sesi tmux
if [[ -n "$TMUX" ]]; then
    echo -e "${RED}[WARNING] Script ini tidak boleh dijalankan dalam sesi tmux!" | tee -a "$LOG_FILE"
    exit 1
fi

# 2. Hapus log lama tanpa mengganggu sesi yang berjalan
echo -e "${YELLOW}[INFO] Menghapus log lama..." | tee -a "$LOG_FILE"
sudo journalctl --vacuum-time=1d
sudo find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;
sudo rm -rf /var/log/*.gz /var/log/*.old

# 3. Hapus cache APT dan file sementara tanpa menghapus sesi Tmux
echo -e "${YELLOW}[INFO] Membersihkan cache sistem..." | tee -a "$LOG_FILE"
sudo apt-get autoremove -y
sudo apt-get clean -y
sudo find /tmp -type f -atime +1 -delete
sudo find /var/tmp -type f -atime +1 -delete

# 4. Hapus file besar di .pm2/logs jika lebih dari 500MB
echo -e "${YELLOW}[INFO] Menghapus log besar di .pm2/logs..." | tee -a "$LOG_FILE"
find /home/hg680p/.pm2/logs -type f -name "*.log" -size +500M -delete

# 5. Optimasi swap dan memori tanpa restart
echo -e "${YELLOW}[INFO] Mengoptimalkan memori dan swap..." | tee -a "$LOG_FILE"
sudo sync && sudo sysctl -w vm.drop_caches=3
sudo swapoff /dev/zram0
echo 536870912 | sudo tee /sys/block/zram0/disksize
sudo mkswap /dev/zram0
sudo swapon /dev/zram0

# 6. Hapus cache thumbnail
echo -e "${YELLOW}[INFO] Menghapus cache thumbnail..." | tee -a "$LOG_FILE"
rm -rf ~/.cache/thumbnails/*

# 7. Restart layanan log tanpa ganggu sesi
echo -e "${YELLOW}[INFO] Mengaktifkan kembali layanan logging..." | tee -a "$LOG_FILE"
sudo systemctl restart rsyslog
sudo systemctl restart systemd-journald

# 8. Hapus log PM2 yang besar
echo -e "${YELLOW}[INFO] Menghapus log PM2 yang besar..." | tee -a "$LOG_FILE"
sudo truncate -s 0 /home/hg680p/.pm2/pm2.log
sudo rm -rf /home/hg680p/.pm2/logs/*

# 9. Batasi ukuran log PM2 agar tidak membesar
echo -e "${YELLOW}[INFO] Mengatur batas ukuran log PM2 ke 100MB..." | tee -a "$LOG_FILE"
pm2 set pm2:log max_size 100M
pm2 reloadLogs

# 10. Hapus log PM2 tanpa mengganggu sesi
echo -e "${YELLOW}[INFO] Menghapus log PM2 tanpa mengganggu sesi..." | tee -a "$LOG_FILE"
pm2 flush

# 11. Menampilkan status setelah pembersihan
echo -e "${GREEN}====================================" | tee -a "$LOG_FILE"
echo -e "${YELLOW}Pembersihan & Optimasi Selesai!" | tee -a "$LOG_FILE"
echo -e "${GREEN}====================================" | tee -a "$LOG_FILE"

df -h | tee -a "$LOG_FILE"
free -h | tee -a "$LOG_FILE"
