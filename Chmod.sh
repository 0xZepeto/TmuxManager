#!/bin/bash

# Simpan perubahan lokal sebelum menarik update
git stash

# Tarik update terbaru dari repo
git pull

# Kembalikan perubahan lokal yang sebelumnya disimpan
git stash pop

# Berikan izin eksekusi ke semua file .sh
find . -type f -name "*.sh" -exec chmod +x {} \;

echo "Update selesai! Semua file .sh telah diberikan izin eksekusi."
