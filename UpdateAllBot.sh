#!/bin/bash

# Warna teks untuk estetika
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RED='\033[1;31m'
CYAN='\033[1;36m'
RESET='\033[0m'

# Fungsi untuk menampilkan header dengan efek mengetik cepat
show_header() {
    clear
    text=(
        "▒█▀▀▀█ █░█ █▀▀ █▀▀█ █░░█ █▀▀█ ▀▀█▀▀ █▀▀█"
        "░▄▄▄▀▀ ▄▀▄ █░░ █▄▄▀ █▄▄█ █░░█ ░░█░░ █░░█"
        "▒█▄▄▄█ ▀░▀ ▀▀▀ ▀░▀▀ ▄▄▄█ █▀▀▀ ░░▀░░ ▀▀▀▀"
    )

    echo -e "${CYAN}"
    for line in "${text[@]}"; do
        for ((i = 0; i < ${#line}; i++)); do
            echo -n "${line:i:1}"
            sleep 0.00008
        done
        echo ""
    done
}

# Fungsi untuk menampilkan teks di tengah
print_centered() {
    local text="$1"
    local width=41  # Mengurangi panjang garis sebanyak 9 karakter
    local padding=$(( (width - ${#text}) / 2 ))
    local line=$(printf '=%.0s' $(seq 1 $width))

    echo -e "${GREEN}${line}${RESET}"
    printf "${YELLOW}%*s%s%*s${RESET}\n" "$padding" "" "$text" "$padding" ""
    echo -e "${GREEN}${line}${RESET}"
}

# Fungsi animasi progress bar
progress_bar() {
    echo -ne "${YELLOW}"
    for i in {1..20}; do
        echo -n "▓"
        sleep 0.05
    done
    echo -e " ✔️ Done${RESET}"  # Mengganti ✅ dengan ✔️
}

# Panggil fungsi header
show_header
print_centered "MEMULAI UPDATE SEMUA BOT..."

# Daftar bot yang akan diperbarui
BOTS=(
    "NGARIT:/home/hg680p/NGARIT"
    "DEPINED:/home/hg680p/Depined-BOT"
    "DEPINED:/home/hg680p/depinedBot"
    "MYGATE:/home/hg680p/mygateBot"
    "MEOWTOPIA:/home/hg680p/meowBot"
    "TEAFI:/home/hg680p/teaFiBot"
    "DESPEED:/home/hg680p/despeedBot"
    "LAYEREDGE:/home/hg680p/LayerEdge-BOT"
    "OASIS-Ai:/home/hg680p/oasis-bot"
    "LISK:/home/hg680p/liskPortsl"
    "BERATRAX:/home/hg680p/beratraxBot"
    "TAKER:/home/hg680p/takerBot"
    "MESHCHAIN:/home/hg680p/mesh-bot"
    "DAWN:/home/hg680p/Dawn-BOT"
    "BLESS:/home/hg680p/bless-bot"
    "TENEO:/home/hg680p/teneo-bot"
    "NAORIS:/home/hg680p/Naoris-BOT"
    "CAPFIZZ:/home/hg680p/Capfizz-BOT"
    "OpenLedger:/home/hg680p/opledBot"
    "MULTIPLE:/home/hg680p/MultipleLite-BOT"
    "FUNCTOR:/home/hg680p/FunctorNode-BOT"
    "STREAM-Ai:/home/hg680p/StreamAi-BOT"
    "ASSISTER:/home/hg680p/Assisterr-BOT"
  # ❌ "PIPE:/home/hg680p/PIPE"
)

# Loop untuk update setiap bot
for BOT in "${BOTS[@]}"; do
    IFS=":" read -r BOT_NAME BOT_PATH <<< "$BOT"

    if [ -d "$BOT_PATH" ]; then
        echo -e "\n${YELLOW}[UPDATING] $BOT_NAME...${RESET}"  # Mengubah warna UPDATING menjadi kuning
        cd "$BOT_PATH"

        if [ -d ".git" ]; then
            # Jalankan git pull dengan fast-forward only, simpan output
            GIT_OUTPUT=$(git pull --ff-only 2>&1)
            
            # Animasi progress bar
            progress_bar
            
            # Tampilkan output git pull setelah selesai
            echo -e "${GREEN}$GIT_OUTPUT${RESET}"
        else
            echo -e "${RED}[SKIPPED] $BOT_NAME bukan repository Git, melewati...${RESET}"
        fi
    else
        echo -e "${RED}[ERROR] Folder $BOT_NAME tidak ditemukan!${RESET}"
    fi
done

print_centered "✔️ SEMUA BOT TELAH DIPERBARUI!"
