#!/bin/bash
# VIN Main Interface
# This script provides the main interface for VIN

# Set current directory to the script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

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

# Function to clear the screen and display the animation
display_animation() {
    clear
    if [ -f "$SCRIPT_DIR/animations/waifu.txt" ]; then
        cat "$SCRIPT_DIR/animations/waifu.txt"
    else
        echo "Animation file not found"
    fi
    sleep 2
    clear
    if [ -f "$SCRIPT_DIR/logo.txt" ]; then
        cat "$SCRIPT_DIR/logo.txt"
    else
        echo "Logo file not found"
    fi
    echo -e "\n\033[1;36mVIN - Type 'help' for information\033[0m\n"
}

# Function to set a custom prompt for the VIN environment
set_custom_prompt() {
    export PS1='\033[1;35m[VIN]\033[1;33m \u \033[1;34m\w \033[1;36m> \033[0m'
}

# Setup chat command aliases for direct access to waifus
setup_waifu_aliases() {
    # Clear existing aliases first
    unalias $(alias | grep -o "^[^=]*") 2>/dev/null || true
    
    # Set standard command aliases
    alias update="bash $SCRIPT_DIR/commands/pkg.sh update"
    alias install="bash $SCRIPT_DIR/commands/pkg.sh install"
    alias remove="bash $SCRIPT_DIR/commands/pkg.sh remove"
    alias system="bash $SCRIPT_DIR/commands/system.sh"
    alias chatbot="bash $SCRIPT_DIR/commands/chatbot.sh"
    
    # Set direct waifu access aliases
    if [ -d "$VINOS_CONFIG/chatbot" ]; then
        for waifu_file in "$VINOS_CONFIG/chatbot"/*.conf; do
            # Skip if there are no files or if it's the API key file
            if [ ! -f "$waifu_file" ] || [ "$(basename "$waifu_file")" = "api_key.conf" ]; then
                continue
            fi
            
            # Get the waifu name from the filename
            waifu_name=$(basename "$waifu_file" .conf)
            
            # Create an alias for direct access to this waifu
            alias "$waifu_name"="bash $SCRIPT_DIR/commands/waifu-bot.sh chat $waifu_name"
        done
    fi
}

# Function to handle user commands
handle_command() {
    local cmd="$1"
    shift
    
    case "$cmd" in
        "help")
            bash "$SCRIPT_DIR/commands/help.sh" "$@"
            ;;
        "exit")
            echo "Exiting VIN. Goodbye!"
            exit 0
            ;;
        "update")
            bash "$SCRIPT_DIR/commands/pkg.sh" update
            ;;
        "install")
            bash "$SCRIPT_DIR/commands/pkg.sh" install "$@"
            ;;
        "remove")
            bash "$SCRIPT_DIR/commands/pkg.sh" remove "$@"
            ;;
        "system")
            bash "$SCRIPT_DIR/commands/system.sh" "$@"
            ;;
        "chatbot"|"waifu-bot")
            bash "$SCRIPT_DIR/commands/waifu-bot.sh" "$@"
            # Re-setup waifu aliases in case new ones were created
            setup_waifu_aliases
            ;;
        *)
            # Check if this is a direct waifu name
            if [ -f "$VINOS_CONFIG/chatbot/$cmd.conf" ]; then
                bash "$SCRIPT_DIR/commands/waifu-bot.sh" chat "$cmd" "$@"
                return
            fi
            
            # Check if the command is a script in the commands directory
            if [ -f "$SCRIPT_DIR/commands/$cmd" ] || [ -f "$SCRIPT_DIR/commands/$cmd.sh" ]; then
                if [ -f "$SCRIPT_DIR/commands/$cmd.sh" ]; then
                    bash "$SCRIPT_DIR/commands/$cmd.sh" "$@"
                else
                    bash "$SCRIPT_DIR/commands/$cmd" "$@"
                fi
                return
            fi
            
            # Pass through other commands to the system
            $cmd "$@"
            ;;
    esac
}

# Main function
main() {
    # Display animation and welcome message
    display_animation
    
    # Set custom prompt
    set_custom_prompt
    
    # Setup waifu aliases for direct access
    setup_waifu_aliases
    
    # Check for required chatbot directories
    mkdir -p "$VINOS_CONFIG/chatbot"
    mkdir -p "$VINOS_DIR/commands/chatbot"
    
    # Make sure the chatbot commands are executable
    chmod +x "$SCRIPT_DIR/commands/waifu-bot.sh" 2>/dev/null || true
    chmod +x "$SCRIPT_DIR/commands/chatbot.sh" 2>/dev/null || true
    
    # Interactive mode
    while true; do
        read -e -p "$(echo -e $PS1)" cmd args
        
        if [ -z "$cmd" ]; then
            continue
        fi
        
        handle_command $cmd $args
    done
}

# Start the main function
main
