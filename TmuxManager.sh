#!/bin/bash

# Kode warna ANSI
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m'   # No Color
BOLD='\033[1m'

# Fungsi animasi ASCII dengan kecepatan 0.0008 detik per karakter
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
    echo -e "${NC}"
    echo -e "${BOLD}${YELLOW}         TMUX MANAGER By 0xRizal${NC}"
    echo -e "${CYAN}>>>>>>>>=========================<<<<<<<<${NC}"
    echo -e "${WHITE}  USE ↑/↓ TO NAVIGATE, ENTER TO SELECT${NC}"
    echo -e "${CYAN}-----------------------------------------${NC}"
}

# Fungsi menu utama
menu() {
    local options=("LIHAT DAFTAR SESI" "BUAT SESI BARU" "HAPUS SESI" "KELUAR")
    local selected=0

    while true; do
        clear
        show_header

        for i in "${!options[@]}"; do
            option_upper=$(echo "${options[i]}" | tr 'a-z' 'A-Z')
            if [[ $i -eq $selected ]]; then
                printf "${BOLD}${YELLOW}%10s > %-20s${NC}\n" "$(($i+1))." "$option_upper"
            else
                printf "${WHITE}%10s   %-20s${NC}\n" "$(($i+1))." "$option_upper"
            fi
        done

        echo -e "${CYAN}-----------------------------------------${NC}"

        read -rsn1 input
        case $input in
            $'\x1B') 
                read -rsn2 -t 0.1 input
                case $input in
                    '[A') ((selected--)); if [[ $selected -lt 0 ]]; then selected=$((${#options[@]} - 1)); fi ;;
                    '[B') ((selected++)); if [[ $selected -ge ${#options[@]} ]]; then selected=0; fi ;;
                esac ;;
            '') 
                case $selected in
                    0) list_sessions ;;
                    1) create_session ;;
                    2) delete_session ;;
                    3) exit_animation ;;
                esac ;;
        esac
    done
}

# Fungsi daftar sesi TMUX
list_sessions() {
    clear
    show_header
    sessions=$(tmux list-sessions 2>/dev/null)

    echo -e "${WHITE}=========================================${NC}"
    echo -e "${BOLD}${YELLOW}  NO   SESI            WINDOWS${NC}"
    echo -e "${CYAN}-----------------------------------------${NC}"

    session_names=()
    index=1
    if [[ -z "$sessions" ]]; then
        echo -e "${CYAN}        Tidak ada sesi aktif.${NC}"
    else
        while IFS= read -r session; do
            session_name=$(echo "$session" | cut -d ':' -f 1)
            session_windows=$(echo "$session" | grep -oP '\d+(?= windows)')
            printf "${WHITE}  %-4s %-15s ${CYAN}%-5s windows${NC}\n" "$index." "$session_name" "$session_windows"
            session_names+=("$session_name")
            ((index++))
        done <<< "$sessions"
    fi

    echo -e "${CYAN}-----------------------------------------${NC}"
    echo -n -e "${CYAN}Pilih nomor sesi untuk masuk [Enter untuk kembali]: ${NC}"
    read -r session_index
    if [[ -n "$session_index" && "$session_index" -gt 0 && "$session_index" -le "${#session_names[@]}" ]]; then
        tmux attach-session -t "${session_names[$((session_index - 1))]}"
    else
        menu
    fi
}

# Fungsi membuat sesi baru
create_session() {
    clear
    show_header
    echo -n -e "${CYAN}Masukkan nama sesi baru: ${NC}"
    read -r session_name
    if tmux new-session -d -s "$session_name"; then
        echo -e "${CYAN}Sesi $session_name berhasil dibuat.${NC}"
    else
        echo -e "${YELLOW}Gagal membuat sesi. Pastikan nama tidak duplikat.${NC}"
    fi
    read -n 1 -s -r -p "[ Enter untuk kembali ke menu ]=>"
    menu
}

# Fungsi menghapus sesi
delete_session() {
    clear
    show_header
    sessions=$(tmux list-sessions 2>/dev/null)

    echo -e "${WHITE}=========================================${NC}"
    echo -e "${BOLD}${YELLOW}  PILIH SESI UNTUK DIHAPUS${NC}"
    echo -e "${CYAN}-----------------------------------------${NC}"
    
    session_names=()
    index=1
    if [[ -z "$sessions" ]]; then
        echo -e "${CYAN}        Tidak ada sesi aktif.${NC}"
    else
        while IFS= read -r session; do
            session_name=$(echo "$session" | cut -d ':' -f 1)
            printf "${WHITE}  %-4s %-20s${NC}\n" "$index." "$session_name"
            session_names+=("$session_name")
            ((index++))
        done <<< "$sessions"
    fi

    echo -e "${CYAN}-----------------------------------------${NC}"
    echo -n -e "${CYAN}Pilih nomor sesi untuk dihapus [Enter untuk kembali]: ${NC}"
    read -r session_index
    if [[ -n "$session_index" && "$session_index" -gt 0 && "$session_index" -le "${#session_names[@]}" ]]; then
        tmux kill-session -t "${session_names[$((session_index - 1))]}"
        echo -e "${CYAN}Sesi berhasil dihapus.${NC}"
    fi
   
 menu
}

# Fungsi animasi keluar lebih cepat
exit_animation() {
    echo -e "${YELLOW}Keluar...${NC}"
    sleep 0.3
    exit 0
}

# Mulai menu utama
menu
