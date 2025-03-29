#!/bin/bash
# VIN Termux Setup Script
# This script sets up VIN in a Termux environment

# Set current directory to the script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Define paths for development environment
VINOS_DIR="$BASE_DIR/usr/share/vinos"
VINOS_CONFIG="$BASE_DIR/etc/vinos"
BIN_DIR="$BASE_DIR/bin"

# Define Termux-specific paths for actual deployment
TERMUX_PREFIX="/data/data/com.termux/files/usr"
TERMUX_HOME="/data/data/com.termux/files/home"

# Load language configuration if available
if [ -f "$VINOS_CONFIG/language.conf" ]; then
    source "$VINOS_CONFIG/language.conf"
    if [ -f "$SELECTED_LANG" ]; then
        source "$SELECTED_LANG"
    else
        # Default to English if selected language not found
        source "$VINOS_DIR/languages/en.conf"
    fi
else
    # Default to English if no language selection made
    source "$VINOS_DIR/languages/en.conf"
fi

echo "========================="
echo "  VIN $LANG_TERMUX"
echo "========================="
echo

# Determine if we're running in an actual Termux environment
if [ -d "$TERMUX_PREFIX" ]; then
    IS_REAL_TERMUX=true
    echo "Running in actual Termux environment."
else
    IS_REAL_TERMUX=false
    echo "Running in development environment (simulating Termux)."
fi

# Create necessary directories
echo "Creating directories..."
mkdir -p "$VINOS_CONFIG"
mkdir -p "$VINOS_CONFIG/chatbot"
mkdir -p "$VINOS_DIR/commands/chatbot"

# Check if we need to install packages for actual Termux
if [ "$IS_REAL_TERMUX" = true ] && command -v pkg >/dev/null 2>&1; then
    echo "$LANG_INSTALLING"
    pkg update
    pkg install -y figlet toilet ncurses-utils coreutils curl jq
else
    echo "Development mode: Would install figlet, toilet, ncurses-utils, coreutils, curl, jq"
    echo "For actual Termux installation, run: pkg install -y figlet toilet ncurses-utils coreutils curl jq"
fi

# Configure repositories
echo "Configuring repositories..."
if [ ! -f "$VINOS_CONFIG/repositories.conf" ]; then
    cp "$SCRIPT_DIR/repositories.conf" "$VINOS_CONFIG/repositories.conf" 2>/dev/null || echo "Could not copy repositories.conf"
fi

# Set up the vin command
echo "Setting up vin command..."
chmod +x "$SCRIPT_DIR/vinos.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/commands/help.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/commands/system.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/commands/pkg.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/commands/waifu-bot.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/commands/chatbot.sh" 2>/dev/null || true
find "$SCRIPT_DIR/commands/chatbot" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
chmod +x "$BIN_DIR/vin" 2>/dev/null || true

# Add vin command to Termux startup if in real Termux
if [ "$IS_REAL_TERMUX" = true ]; then
    echo "Configuring Termux startup..."
    if [ -f "$TERMUX_HOME/.bashrc" ]; then
        if ! grep -q "VIN" "$TERMUX_HOME/.bashrc"; then
            echo "" >> "$TERMUX_HOME/.bashrc"
            echo "# VIN Configuration" >> "$TERMUX_HOME/.bashrc"
            echo "alias vin='$TERMUX_PREFIX/bin/vin'" >> "$TERMUX_HOME/.bashrc"
            echo "" >> "$TERMUX_HOME/.bashrc"
        fi
    else
        echo "# VIN Configuration" > "$TERMUX_HOME/.bashrc"
        echo "alias vin='$TERMUX_PREFIX/bin/vin'" >> "$TERMUX_HOME/.bashrc"
        echo "" >> "$TERMUX_HOME/.bashrc"
    fi
else
    echo "Development mode: Would configure Termux startup."
fi

# Update permissions
chmod -R 755 "$SCRIPT_DIR" 2>/dev/null || true
find "$SCRIPT_DIR" -name "*.txt" -exec chmod 644 {} \; 2>/dev/null || true
find "$SCRIPT_DIR/animations" -name "*.txt" -exec chmod 644 {} \; 2>/dev/null || true
find "$SCRIPT_DIR" -name "*.sh" -exec chmod 755 {} \; 2>/dev/null || true
find "$SCRIPT_DIR/commands" -name "*.sh" -exec chmod 755 {} \; 2>/dev/null || true

# Show features
echo
echo "=========================="
echo "$LANG_FEATURES"
echo "=========================="
echo "- $LANG_FEATURE1"
echo "- $LANG_FEATURE2"
echo "- $LANG_FEATURE3"
echo "- $LANG_FEATURE4"
echo "- $LANG_FEATURE5"
echo

echo "$LANG_COMPLETE"
if [ "$IS_REAL_TERMUX" = true ]; then
    echo "$LANG_START"
    echo "$LANG_RESTART"
else
    echo "In development mode. To start VIN, run: $BIN_DIR/vin senpai"
fi
echo

exit 0
