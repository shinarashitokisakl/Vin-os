#!/bin/bash
# VIN Installer Script
# This script installs VIN components on a Linux system

# Set current directory to the script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Define installation directories - for local development setup
VINOS_DIR="$BASE_DIR/usr/share/vinos"
VINOS_CONFIG="$BASE_DIR/etc/vinos"
BIN_DIR="$BASE_DIR/bin"

# Language selection function
select_language() {
    echo "==============================="
    echo "  VIN - Language Selection    "
    echo "==============================="
    echo "1. English"
    echo "2. Bahasa Indonesia"
    echo "==============================="
    read -p "Select language/Pilih bahasa [1-2]: " lang_choice
    
    case $lang_choice in
        1)
            LANG_FILE="$SCRIPT_DIR/languages/en.conf"
            ;;
        2)
            LANG_FILE="$SCRIPT_DIR/languages/id.conf"
            ;;
        *)
            echo "Invalid selection, defaulting to English"
            LANG_FILE="$SCRIPT_DIR/languages/en.conf"
            ;;
    esac
    
    # Source the language file
    source "$LANG_FILE"
    
    # Save selected language
    echo "SELECTED_LANG=$LANG_FILE" > "$VINOS_CONFIG/language.conf"
}

# Determine if we're running in Termux
if [ -d "/data/data/com.termux/files/usr" ]; then
    IS_TERMUX=true
else
    IS_TERMUX=false
fi

# Create necessary directories
mkdir -p "$VINOS_CONFIG"

# Select language first
select_language

echo "=========================="
echo "  $LANG_WELCOME"
echo "=========================="
echo

# Show detected environment
if [ "$IS_TERMUX" = true ]; then
    echo "Detected Termux environment."
    echo "$LANG_INSTALL_TYPE $LANG_TERMUX"
    echo
    bash "$SCRIPT_DIR/termux_setup.sh"
    exit $?
fi

echo "$LANG_INSTALL_TYPE $LANG_STANDARD"
echo

# Check if we need to install packages
if command -v apt >/dev/null 2>&1; then
    echo "$LANG_INSTALLING"
    # In a real system, you would use:
    # sudo apt update
    # sudo apt install -y figlet toilet lolcat coreutils
    # But for development, we'll just print this
    echo "Would install: figlet toilet lolcat coreutils"
    echo "For actual installation, run: sudo apt install -y figlet toilet lolcat coreutils"
fi

# Configure repositories
echo "Configuring repositories..."
if [ ! -f "$VINOS_CONFIG/repositories.conf" ]; then
    cp "$SCRIPT_DIR/repositories.conf" "$VINOS_CONFIG/repositories.conf" 2>/dev/null || echo "Could not copy repositories.conf"
fi

# Ask about enabling Kali repositories
read -p "$LANG_ENABLE_KALI" enable_kali
if [[ "$enable_kali" =~ ^[Yy]$ ]]; then
    # Ensure we have the kali.list directory
    mkdir -p "$BASE_DIR/etc/apt/sources.list.d"
    echo "# Kali Linux repositories for VIN" > "$BASE_DIR/etc/apt/sources.list.d/kali.list"
    echo "# These repositories contain security tools and should be used responsibly" >> "$BASE_DIR/etc/apt/sources.list.d/kali.list"
    echo "" >> "$BASE_DIR/etc/apt/sources.list.d/kali.list"
    echo "# Main Kali repository" >> "$BASE_DIR/etc/apt/sources.list.d/kali.list"
    echo "deb http://http.kali.org/kali kali-rolling main non-free contrib" >> "$BASE_DIR/etc/apt/sources.list.d/kali.list"
    echo "$LANG_KALI_ENABLED"
    echo "$LANG_KALI_WARNING"
else
    # Ensure we have the kali.list directory
    mkdir -p "$BASE_DIR/etc/apt/sources.list.d"
    echo "# Kali Linux repositories for VIN" > "$BASE_DIR/etc/apt/sources.list.d/kali.list"
    echo "# Only uncomment these lines if you know what you're doing!" >> "$BASE_DIR/etc/apt/sources.list.d/kali.list"
    echo "" >> "$BASE_DIR/etc/apt/sources.list.d/kali.list"
    echo "# Main Kali repository" >> "$BASE_DIR/etc/apt/sources.list.d/kali.list"
    echo "# deb http://http.kali.org/kali kali-rolling main non-free contrib" >> "$BASE_DIR/etc/apt/sources.list.d/kali.list"
    echo "$LANG_KALI_DISABLED"
fi

# Set up the vin command
echo "Setting up vin command..."
chmod +x "$SCRIPT_DIR/vinos.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/commands/help.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/commands/system.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/commands/pkg.sh" 2>/dev/null || true
chmod +x "$BIN_DIR/vin" 2>/dev/null || true

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
echo "$LANG_START"
echo "$LANG_RESTART"
echo

exit 0
