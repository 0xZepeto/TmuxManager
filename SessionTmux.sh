#!/bin/bash

# Definisikan warna untuk estetika
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

# Fungsi animasi loading spinner
spinner() {
    local pid=$1
    local delay=0.1
    local spin='|/-\'
    while ps -p $pid > /dev/null; do
        for i in $(seq 0 3); do
            echo -ne "\r${BLUE}Memproses... ${spin:$i:1} ${RESET}"
            sleep $delay
        done
    done
    echo -ne "\r${GREEN}✓ Selesai! ${RESET}                     \n"
}

# Header dan pesan pembuka dengan gambar ASCII
clear
echo -e "${GREEN}==========================================================="
echo -e "${YELLOW}            ▀█ ▀▄▀ █▀▀ █▀█ █▄█ █▀█ ▀█▀ █▀█            "
echo -e "${YELLOW}            █▄ █░█ █▄▄ █▀▄ ░█░ █▀▀ ░█░ █▄█            "
echo -e "${GREEN}==========================================================="
echo -e "${YELLOW}       ⚡ WELCOME TO THE AUTOMATED BOT LAUNCHER ⚡               "
echo -e "${GREEN}==========================================================="
echo ""

# Daftar bot tanpa input otomatis
BOTS_NO_INPUT=(
    "DEPINED:/home/hg680p/Depined-BOT:node main.js:"
    "MEOWTOPIA:/home/hg680p/meowBot:node main.js:"
    "LAYEREDGE:/home/hg680p/LedgeBot:node main.js:"
    "OASIS-Ai:/home/hg680p/Oasis:node main.js:"
    "FRACTION-Ai:/home/hg680p/FractionAI-BOT:npm start:"
    "WALME:/home/hg680p/Walme-Auto-Bot:node index.js:"
    "FireVerse:/home/hg680p/Fireverse-Auto-Bot:node index.js:"
    "MELOD-AI:/home/hg680p/Agent:node melodai.js:"
    "HACKQUEST:/home/hg680p/Agent:node hq.js:"
    "DAWN:/home/hg680p/Dawn-BOT:node main.js:"
    "ZOOP:/home/hg680p/Agent:node zoop.js:"
    #STB8✅"LAYEREDGE_17k:/home/hg680p/LayerEdge-Auto-Bot:node main.js:"
    "MYGATE:/home/hg680p/mygateBot:node main.js:"

    
    #"AGNTHUB:/home/hg680p/Agent:node agnt.js:"
    #"SOGNI:/home/hg680p/Agent:node dailysogni.js:"
    #STB1"COC:/home/hg680p/Agent:node cocnew.js:"
    #"NODEGO:/home/hg680p/NodeGo-Auto-Bot:node index.js:"
    #"STORK:/home/hg680p/Stork-Auto-Bot:node index.js:"

   
    #❌"3DOS:/home/hg680p/3Dos-Auto-Bot:node index.js:"
    #❌"GATA:/home/hg680p/Gata-Auto-Bot:node index.js:"
    #❌"OpenLedger:/home/hg680p/opledBot:node main.js:"
    #❌"DESPEED:/home/hg680p/despeedBot:npm run start:"
    #❌"CAPFIZZ:/home/hg680p/Capfizz-BOT:node main.js:"
    #❌"SparkChain:/home/hg680p/Sparkchain-Auto-Bot:node index.js:"
    #❌"SINGULABS:/home/hg680p/Singulabs-Auto-Bot:node index.js:"
    #❌"NGARIT:/home/hg680p/NGARIT:node index.js:"
    #❌"GRASS:/home/hg680p/grass-network-bot:node index.js:Down C-m"
    #❌<BOT ERROR>"TAKER:/home/hg680p/takerBot:node main.js:"
    #❌<BOT ERROR>"MESHCHAIN:/home/hg680p/mesh-bot:node main.js:"
    #❌<BOT ERROR>"LITAS:/home/hg680p/litasBot:node main.js:"
)

# Daftar bot dengan input otomatis
BOTS_WITH_INPUT=(
    #"BLESS:/home/hg680p/bless-bot:node main.js:n"
    #"TENEO:/home/hg680p/teneo-bot:node index.js:y n y"
)

# Fungsi untuk menjalankan bot dalam tmux dengan efek loading
start_bot() {
    local SESSION=$1
    local FOLDER=$2
    local COMMAND=$3
    local INPUTS=$4

    if tmux has-session -t "$SESSION" 2>/dev/null; then
        echo -e "${BLUE}$SESSION sudah berjalan.${RESET}"
    else
        echo -e "${YELLOW}▶ Menjalankan $SESSION...${RESET}"
        tmux new-session -s "$SESSION" -d
        tmux send-keys -t "$SESSION" "cd $FOLDER" C-m
        tmux send-keys -t "$SESSION" "$COMMAND" C-m &
        spinner $!
        
        # Kirim input otomatis jika ada
        if [[ "$SESSION" != "FUNCTOR" ]]; then
            sleep 2
            for INPUT in $INPUTS; do
                tmux send-keys -t "$SESSION" "$INPUT" C-m
                sleep 1
            done
            echo -e "${GREEN}✓ Input otomatis dikirim ke $SESSION: $INPUTS${RESET}"
        fi
    fi
}

# Loop untuk menjalankan bot tanpa input otomatis
for BOT in "${BOTS_NO_INPUT[@]}"; do
    IFS=":" read -r SESSION FOLDER COMMAND INPUTS <<< "$BOT"
    start_bot "$SESSION" "$FOLDER" "$COMMAND" "$INPUTS"
done

# Fungsi untuk menjalankan bot dengan aktivasi venv + efek loading
start_bot_with_venv() {
    local SESSION=$1
    local FOLDER=$2
    local COMMAND=$3
    local VENV=$4

    if tmux has-session -t "$SESSION" 2>/dev/null; then
        echo -e "${BLUE}$SESSION sudah berjalan.${RESET}"
    else
        echo -e "${YELLOW}▶ Menjalankan $SESSION dengan virtual environment...${RESET}"
        tmux new-session -s "$SESSION" -d
        tmux send-keys -t "$SESSION" "source $VENV" C-m
        sleep 2
        tmux send-keys -t "$SESSION" "cd $FOLDER" C-m
        tmux send-keys -t "$SESSION" "$COMMAND" C-m &
        spinner $!
        
        # Kirim pilihan 3 setelah bot berjalan
        sleep 2
        tmux send-keys -t "$SESSION" "3" C-m
        echo -e "${GREEN}✓ Input otomatis '3' dikirim ke $SESSION.${RESET}"
    fi
}

start_bot_with_venv "DREAMQUEST" "/home/hg680p/DreamerQuests-BOT" "python3 bot.py" "/home/hg680p/venv/bin/activate"
start_bot_with_venv "TENEO" "/home/hg680p/Teneo-BOT" "python3 bot.py" "/home/hg680p/venv/bin/activate"
start_bot_with_venv "KIVA" "/home/hg680p/Kivanet-BOT" "python3 bot.py" "/home/hg680p/venv/bin/activate"
start_bot_with_venv "CAPFIZ" "/home/hg680p/Capfizz-BOT" "python3 bot.py" "/home/hg680p/venv/bin/activate"
#STB8✅start_bot_with_venv "DEPINED" "/home/hg680p/depinedBot" "python3 bot.py" "/home/hg680p/venv/bin/activate"
start_bot_with_venv "MULTIPLE" "/home/hg680p/MultipleLite-BOT" "python3 bot.py" "/home/hg680p/venv/bin/activate"
start_bot_with_venv "FUNCTOR" "/home/hg680p/FunctorNode-BOT" "python3 bot.py" "/home/hg680p/venv/bin/activate"
start_bot_with_venv "STREAM-Ai" "/home/hg680p/StreamAi-BOT" "python3 bot.py" "/home/hg680p/venv/bin/activate"
start_bot_with_venv "ASSISTER" "/home/hg680p/Assisterr-BOT" "python3 bot.py" "/home/hg680p/venv/bin/activate"

#❌start_bot_with_venv "NAORIS" "/home/hg680p/NaorisNode-BOT" "python3 bot.py" "/home/hg680p/venv/bin/activate"
#❌start_bot_with_venv "UNICH" "/home/hg680p/Unich-BOT" "python3 bot.py" "/home/hg680p/venv/bin/activate"
#❌STB1 start_bot_with_venv "LISK" "/home/hg680p/liskportal" "python3 main.py" "/home/hg680p/venv/bin/activate"
# Menjalankan AIGAEA dengan virtual environment
#❌start_bot_with_venv "AiGaea" "/home/hg680p/AiGaea-BOT" "python3 bot.py" "/home/hg680p/venv/bin/activate"
# Menjalankan PIPE dengan virtual environment
#<error❌>start_bot_with_venv "PIPE" "/home/hg680p/PIPE" "python3 bot.py" "/home/hg680p/venv/bin/activate"
# Menjalankan DAWN dengan virtual environment
#❌start_bot_with_venv "DAWN" "/home/hg680p/Dawn-BOT" "python3 bot.py" "/home/hg680p/venv/bin/activate"

# Loop untuk menjalankan bot dengan input otomatis
for BOT in "${BOTS_WITH_INPUT[@]}"; do
    IFS=":" read -r SESSION FOLDER COMMAND INPUTS <<< "$BOT"
    start_bot "$SESSION" "$FOLDER" "$COMMAND" "$INPUTS"
done

#kite
# Jalankan Kite-Ai dengan input otomatis Enter setelah 2 detik
start_bot "KITE-Ai" "/home/hg680p/KiteAi-Auto-Bot" "node index.js"
sleep 2
tmux send-keys -t "KITE-Ai" "" C-m
echo -e "${GREEN}Enter telah dikirim ke KITE-Ai.${RESET}"

start_bot "EXEOS" "/home/hg680p/Exeos-Auto-Bot" "node index.js"
sleep 2
tmux send-keys -t "EXEOS" "" C-m
echo -e "${GREEN}Enter telah dikirim ke EXEOS.${RESET}"

# Jalankan TEA-TARIK dengan input otomatis
start_bot "TEA-TARIK" "/home/hg680p/Tea-Tarik" "node index.js"
sleep 3
tmux send-keys -t "TEA-TARIK" "y" C-m  # Kirim input "y"
sleep 3
tmux send-keys -t "TEA-TARIK" "5" C-m  # Kirim input "5"
sleep 3
tmux send-keys -t "TEA-TARIK" "100" C-m  # Kirim input "100"
echo -e "${GREEN}TEA-TARIK sudah dijalankan dengan input otomatis: y, 2, dan 100 dengan jeda 3 detik.${RESET}"

# Pesan penutupan dengan animasi loading
echo -ne "${YELLOW}⚡ Memastikan semua bot berjalan dengan baik...${RESET}"
sleep 2
echo -ne "\r${GREEN}✅ Semua bot telah berjalan!${RESET}\n"

# Tampilan akhir yang rapi
echo -e "${GREEN}==========================================================="
echo -e "${YELLOW}  [>>>] SEMUA BOT TELAH DIJALANKAN DI TMUX! [<<<]"
echo -e "${GREEN}==========================================================="
