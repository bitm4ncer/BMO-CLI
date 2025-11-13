#!/bin/bash
# Pick a random BMO saying

SAYINGS_FILE="$HOME/.config/fastfetch/bmo_sayings.txt"

# Pick a random line from the sayings file
SAYING=$(shuf -n 1 "$SAYINGS_FILE")

# ANSI color codes: green bold
echo -e "\033[1;32m${SAYING}\033[0m"
