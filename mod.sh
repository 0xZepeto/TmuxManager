#!/bin/bash

# Warna kuning untuk output
YELLOW='\033[1;33m'
RESET='\033[0m'

# Folder target
FOLDER="/home/hg680p/TmuxManager"

# Pindah ke folder TmuxManager
cd "$FOLDER" || exit

# Jalankan git stash dan git pull tanpa output yang mengganggu
git stash -q 2>/dev/null
git pull --quiet 2>/dev/null

# Berikan izin eksekusi ke semua file .sh hanya dalam folder ini (bukan subfolder)
chmod +x "$FOLDER"/*.sh 2>/dev/null

# Pesan selesaiSuccessful
echo -e "${YELLOW}Update Successful!${RESET}"
