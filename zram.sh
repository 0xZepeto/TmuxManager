#!/bin/bash
# =========================================
# Manajemen /var/log pakai ZRAM (zram1 & zram2) dengan animasi dan aman
# =========================================

# Fungsi animasi teks
animasi_teks() {
    local TEKS="$1"
    local DELAY=${2:-0.05}
    for (( i=0; i<${#TEKS}; i++ )); do
        echo -n "${TEKS:$i:1}"
        sleep $DELAY
    done
    echo
}

# Fungsi buat dan setup zram
cek_buat_zram() {
    local ZRAM_NUM=$1
    local SIZE_MB=$2

    sudo modprobe zram

    if [ ! -b "/dev/zram$ZRAM_NUM" ]; then
        echo "Membuat /dev/zram$ZRAM_NUM..."
        echo $ZRAM_NUM | sudo tee /sys/class/zram-control/hot_add >/dev/null
    fi

    # Cek apakah device sedang digunakan
    if ! mount | grep -q "/dev/zram$ZRAM_NUM"; then
        echo lz4 | sudo tee /sys/block/zram$ZRAM_NUM/comp_algorithm >/dev/null
        echo $((SIZE_MB*1024*1024)) | sudo tee /sys/block/zram$ZRAM_NUM/disksize >/dev/null
    fi

    # Format hanya jika belum ada filesystem
    if ! sudo blkid /dev/zram$ZRAM_NUM >/dev/null 2>&1; then
        sudo mkfs.ext4 -q /dev/zram$ZRAM_NUM
    fi
}

# Fungsi pindah /var/log ke zram
pindah_ke_zram() {
    local ZRAM_NUM=$1
    local SIZE_MB=$2
    local LABEL=$3

    cek_buat_zram $ZRAM_NUM $SIZE_MB

    animasi_teks "Moving to $LABEL ..." 0.07

    sudo umount /mnt 2>/dev/null || true
    sudo umount /var/log 2>/dev/null || true
    sudo mount /dev/zram$ZRAM_NUM /mnt
    sudo rsync -a --delete /var/log/ /mnt/
    sudo umount /var/log 2>/dev/null || true
    sudo mount /dev/zram$ZRAM_NUM /var/log

    animasi_teks "$LABEL is ready! ✅" 0.05
    sleep 1
}

# Balik ke zram1
balik_ke_zram1() {
    pindah_ke_zram 1 50 "ZRAM1"
}

# Pindah ke zram2
pindah_ke_zram2() {
    pindah_ke_zram 2 200 "ZRAM2"
}

# Bersihkan zram2
bersihkan_zram2() {
    if [ -b /dev/zram2 ]; then
        animasi_teks "Cleaning ZRAM2 ..." 0.07
        sudo umount /mnt 2>/dev/null || true
        sudo umount /var/log 2>/dev/null || true
        sudo mkfs.ext4 -q /dev/zram2
        animasi_teks "ZRAM2 cleaned! ✅" 0.05
    else
        animasi_teks "ZRAM2 belum dibuat, tidak ada yang dibersihkan." 0.05
    fi
    read -p "Tekan ENTER untuk kembali ke menu..."
}

# Menu whiptail
while true; do
    CHOICE=$(whiptail --title "Manajemen /var/log ZRAM" --menu "Pilih aksi:" 15 60 5 \
    "1" "Gunakan zram1 (default, kecil)" \
    "2" "Gunakan zram2 (cadangan, besar)" \
    "3" "Bersihkan zram2" \
    "4" "Keluar" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) balik_ke_zram1 ;;
        2) pindah_ke_zram2 ;;
        3) bersihkan_zram2 ;;
        4) clear; exit 0 ;;
        *) ;;
    esac
done
