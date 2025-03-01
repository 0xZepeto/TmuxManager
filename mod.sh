#!/bin/bash
YELLOW='\033[1;33m'
RESET='\033[0m'

FOLDER="/home/hg680p/TmuxManager"
cd "$FOLDER" || exit
git stash -q 2>/dev/null
git pull --quiet 2>/dev/null
chmod +x "$FOLDER"/*.sh 2>/dev/null
echo -e "${YELLOW}Update Successful!${RESET}"
