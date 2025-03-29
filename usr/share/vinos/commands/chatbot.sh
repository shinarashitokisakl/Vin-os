#!/bin/bash
# VIN Chatbot command
# This script is a wrapper for the waifu-bot.sh script

# Set current directory to the script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Check if we're running in Termux
if [ -d "/data/data/com.termux/files/usr" ]; then
    export VINOS_DIR="/data/data/com.termux/files/usr/share/vinos"
else
    export VINOS_DIR="$BASE_DIR/usr/share/vinos"
fi

# Call the waifu-bot.sh script with all arguments
"$VINOS_DIR/commands/waifu-bot.sh" "$@"