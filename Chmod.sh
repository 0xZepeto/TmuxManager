#!/bin/bash

git stash && git pull && git stash pop

# Cek apakah ada file .sh sebelum menjalankan chmod
if find . -type f -name "*.sh" | grep -q .; then
    find . -type f -name "*.sh" -exec chmod +x {} \;
    echo "Update selesai! Semua file .sh telah diberikan izin eksekusi."
else
    echo "Tidak ada file .sh yang ditemukan."
fi

