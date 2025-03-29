#!/bin/bash
# VIN Help Command
# This script provides help information for VIN commands

# Set current directory to the script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Check if we're running in Termux
if [ -d "/data/data/com.termux/files/usr" ]; then
    export VINOS_DIR="/data/data/com.termux/files/usr/share/vinos"
    export VINOS_CONFIG="/data/data/com.termux/files/usr/etc/vinos"
    export TERMUX_MODE=true
else
    export VINOS_DIR="$BASE_DIR/usr/share/vinos"
    export VINOS_CONFIG="$BASE_DIR/etc/vinos"
    export TERMUX_MODE=false
fi

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

# Colors for terminal output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# Function to display general help
show_general_help() {
    echo -e "${CYAN}========== VIN Help ==========${NC}"
    echo -e "${YELLOW}Basic Commands:${NC}"
    echo -e "  ${GREEN}help${NC}              - Display this help information"
    echo -e "  ${GREEN}exit${NC}              - Exit VIN interface"
    echo -e "  ${GREEN}help [command]${NC}    - Get help for a specific command"
    echo
    echo -e "${YELLOW}Package Management:${NC}"
    echo -e "  ${GREEN}update${NC}            - Update package lists"
    echo -e "  ${GREEN}install [package]${NC}  - Install a package"
    echo -e "  ${GREEN}remove [package]${NC}   - Remove a package"
    echo
    echo -e "${YELLOW}System Information:${NC}"
    echo -e "  ${GREEN}system info${NC}       - Display system information"
    echo -e "  ${GREEN}system repos${NC}      - Display configured repositories"
    echo -e "  ${GREEN}system update${NC}     - Update VIN components"
    echo
    echo -e "${YELLOW}Waifu Chatbot:${NC}"
    echo -e "  ${GREEN}chatbot${NC} or ${GREEN}waifu-bot${NC} - Waifu chatbot main command"
    echo -e "  ${GREEN}chatbot create${NC}    - Create a new waifu character"
    echo -e "  ${GREEN}chatbot list${NC}      - List all created waifu characters"
    echo -e "  ${GREEN}chatbot chat${NC}      - Chat with a specific waifu"
    echo -e "  ${GREEN}chatbot setkey${NC}    - Set your OpenAI API key"
    echo -e "  ${GREEN}[waifu_name]${NC}      - Chat directly with a created waifu"
    echo
    echo -e "${YELLOW}Additional Help:${NC}"
    echo -e "  You can also use standard Linux commands within the VIN interface."
    echo -e "${CYAN}================================${NC}"
}

# Function to display help for a specific command
show_command_help() {
    local command="$1"
    
    case "$command" in
        "update")
            echo -e "${CYAN}========== Update Command Help ==========${NC}"
            echo -e "Usage: update"
            echo -e "Description: Updates the package lists from all configured repositories."
            echo -e "This ensures you have access to the latest available packages."
            echo -e "${CYAN}=========================================${NC}"
            ;;
        "install")
            echo -e "${CYAN}========== Install Command Help ==========${NC}"
            echo -e "Usage: install [package1] [package2] ..."
            echo -e "Description: Installs one or more packages from the configured repositories."
            echo -e "Examples:"
            echo -e "  install nano          - Install the nano text editor"
            echo -e "  install nmap wireshark - Install multiple packages"
            echo -e "${CYAN}==========================================${NC}"
            ;;
        "remove")
            echo -e "${CYAN}========== Remove Command Help ==========${NC}"
            echo -e "Usage: remove [package1] [package2] ..."
            echo -e "Description: Removes one or more installed packages from the system."
            echo -e "Examples:"
            echo -e "  remove nano          - Remove the nano text editor"
            echo -e "  remove nmap wireshark - Remove multiple packages"
            echo -e "${CYAN}=========================================${NC}"
            ;;
        "system")
            echo -e "${CYAN}========== System Command Help ==========${NC}"
            echo -e "Usage: system [subcommand]"
            echo -e "Description: Provides system-related information and operations."
            echo -e "Subcommands:"
            echo -e "  info   - Display system information"
            echo -e "  repos  - Display configured repositories"
            echo -e "  update - Update VIN components"
            echo -e "${CYAN}=========================================${NC}"
            ;;
        "chatbot"|"waifu-bot")
            echo -e "${CYAN}========== Waifu Chatbot Help ==========${NC}"
            echo -e "Usage: chatbot [subcommand]"
            echo -e "Description: A chatbot with anime character personalities."
            echo -e "Subcommands:"
            echo -e "  create       - Create a new waifu character"
            echo -e "  list         - List all your created waifu characters"
            echo -e "  chat [name]  - Chat with a specific waifu"
            echo -e "  delete [name]- Delete a waifu character"
            echo -e "  setkey       - Set your OpenAI API key"
            echo -e ""
            echo -e "Note: You can also directly chat with a created waifu"
            echo -e "      by typing her name as a command."
            echo -e "Example: If you created a waifu named 'elaina', you"
            echo -e "         can type 'elaina' to start chatting with her."
            echo -e "${CYAN}=========================================${NC}"
            ;;
        *)
            echo -e "${RED}No help available for command: $command${NC}"
            echo -e "Type 'help' for a list of available commands."
            ;;
    esac
}

# Main function
if [ "$#" -eq 0 ]; then
    show_general_help
else
    show_command_help "$1"
fi

exit 0
