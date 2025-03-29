#!/bin/bash
# VIN Waifu Chatbot Command
# This script provides waifu chatbot functionality using OpenAI API

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

# Directory for storing chatbot configurations
CHATBOT_CONFIG_DIR="$VINOS_CONFIG/chatbot"
# Directory for chatbot command scripts
CHATBOT_SCRIPT_DIR="$VINOS_DIR/commands/chatbot"

# Make sure the config directory exists
mkdir -p "$CHATBOT_CONFIG_DIR"

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# Check for curl
if ! command -v curl &> /dev/null; then
    echo -e "${RED}Error: curl is required but not installed.${NC}"
    echo -e "Please install curl first:"
    if [ "$TERMUX_MODE" = true ]; then
        echo -e "  pkg install curl"
    else
        echo -e "  sudo apt install curl"
    fi
    exit 1
fi

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed.${NC}"
    echo -e "Please install jq first:"
    if [ "$TERMUX_MODE" = true ]; then
        echo -e "  pkg install jq"
    else
        echo -e "  sudo apt install jq"
    fi
    exit 1
fi

# Function to show help
show_help() {
    echo -e "${CYAN}========== Waifu Chatbot Help ===========${NC}"
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "  ${GREEN}waifu-bot create${NC} - Create a new waifu chatbot"
    echo -e "  ${GREEN}waifu-bot list${NC} - List all created waifu chatbots"
    echo -e "  ${GREEN}waifu-bot chat <name>${NC} - Chat with a specific waifu"
    echo -e "  ${GREEN}waifu-bot delete <name>${NC} - Delete a waifu profile"
    echo -e "  ${GREEN}waifu-bot setkey${NC} - Set the OpenAI API key"
    echo -e "${CYAN}=======================================${NC}"
}

# Function to set the OpenAI API key
set_api_key() {
    echo -e "${CYAN}Set your OpenAI API Key${NC}"
    echo -e "${YELLOW}This key will be stored locally in $CHATBOT_CONFIG_DIR/api_key.conf${NC}"
    read -p "Enter your OpenAI API key: " api_key
    
    if [ -z "$api_key" ]; then
        echo -e "${RED}Error: API key cannot be empty.${NC}"
        return 1
    fi
    
    # Store the API key
    echo "OPENAI_API_KEY=$api_key" > "$CHATBOT_CONFIG_DIR/api_key.conf"
    chmod 600 "$CHATBOT_CONFIG_DIR/api_key.conf"
    
    echo -e "${GREEN}API key set successfully!${NC}"
}

# Function to check if API key is set
check_api_key() {
    if [ ! -f "$CHATBOT_CONFIG_DIR/api_key.conf" ]; then
        echo -e "${RED}Error: OpenAI API key not found.${NC}"
        echo -e "Please set your API key using: waifu-bot setkey"
        return 1
    fi
    
    source "$CHATBOT_CONFIG_DIR/api_key.conf"
    
    if [ -z "$OPENAI_API_KEY" ]; then
        echo -e "${RED}Error: API key is empty.${NC}"
        echo -e "Please set your API key using: waifu-bot setkey"
        return 1
    fi
    
    return 0
}

# Function to create a new waifu chatbot
create_waifu() {
    echo -e "${CYAN}======== Create New Waifu ========${NC}"
    echo -e "${YELLOW}Let's create your custom waifu character!${NC}"
    
    read -p "Enter waifu name: " waifu_name
    
    if [ -z "$waifu_name" ]; then
        echo -e "${RED}Error: Waifu name cannot be empty.${NC}"
        return 1
    fi
    
    # Check if the name already exists
    if [ -f "$CHATBOT_CONFIG_DIR/$waifu_name.conf" ]; then
        echo -e "${RED}Error: A waifu with this name already exists.${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Enter waifu personality (e.g., shy, cheerful, tsundere):${NC}"
    read -p "> " waifu_personality
    
    echo -e "${YELLOW}Enter additional character traits (hobbies, background, etc.):${NC}"
    read -p "> " waifu_traits
    
    echo -e "${YELLOW}What should the waifu call you?${NC}"
    read -p "> " user_name
    
    # Create the waifu configuration file
    cat > "$CHATBOT_CONFIG_DIR/$waifu_name.conf" << EOF
WAIFU_NAME="$waifu_name"
WAIFU_PERSONALITY="$waifu_personality"
WAIFU_TRAITS="$waifu_traits"
USER_NAME="$user_name"
CHAT_HISTORY=()
EOF
    
    # Create a launcher script for this waifu
    cat > "$CHATBOT_SCRIPT_DIR/$waifu_name.sh" << EOF
#!/bin/bash
# Auto-generated waifu chatbot script
"$VINOS_DIR/commands/waifu-bot.sh" chat "$waifu_name" "\$@"
EOF
    
    # Make the launcher script executable
    chmod +x "$CHATBOT_SCRIPT_DIR/$waifu_name.sh"
    
    echo -e "${GREEN}Waifu '$waifu_name' created successfully!${NC}"
    echo -e "You can chat with her by typing: ${CYAN}waifu-bot chat $waifu_name${NC}"
    echo -e "Or use the direct command: ${CYAN}$waifu_name${NC}"
}

# Function to list all created waifus
list_waifus() {
    echo -e "${CYAN}======== Your Waifu Collection ========${NC}"
    
    # Count the number of waifu configuration files
    waifu_count=$(find "$CHATBOT_CONFIG_DIR" -name "*.conf" ! -name "api_key.conf" | wc -l)
    
    if [ "$waifu_count" -eq 0 ]; then
        echo -e "${YELLOW}You haven't created any waifus yet.${NC}"
        echo -e "Create one with: ${CYAN}waifu-bot create${NC}"
        return 0
    fi
    
    echo -e "${GREEN}You have $waifu_count waifu(s):${NC}"
    
    for waifu_file in "$CHATBOT_CONFIG_DIR"/*.conf; do
        # Skip the API key file
        if [ "$(basename "$waifu_file")" = "api_key.conf" ]; then
            continue
        fi
        
        # Source the waifu configuration
        source "$waifu_file"
        
        echo -e "${PURPLE}$WAIFU_NAME${NC} - $WAIFU_PERSONALITY"
        echo -e "  ${BLUE}Traits:${NC} $WAIFU_TRAITS"
        echo -e "  ${BLUE}Calls you:${NC} $USER_NAME"
        echo
    done
}

# Function to delete a waifu
delete_waifu() {
    if [ "$#" -ne 1 ]; then
        echo -e "${RED}Error: Please specify a waifu name to delete.${NC}"
        echo -e "Usage: waifu-bot delete <name>"
        return 1
    fi
    
    waifu_name="$1"
    waifu_file="$CHATBOT_CONFIG_DIR/$waifu_name.conf"
    waifu_script="$CHATBOT_SCRIPT_DIR/$waifu_name.sh"
    
    if [ ! -f "$waifu_file" ]; then
        echo -e "${RED}Error: Waifu '$waifu_name' not found.${NC}"
        return 1
    fi
    
    read -p "Are you sure you want to delete waifu '$waifu_name'? (y/n): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -f "$waifu_file"
        rm -f "$waifu_script"
        echo -e "${GREEN}Waifu '$waifu_name' deleted successfully.${NC}"
    else
        echo -e "${YELLOW}Deletion cancelled.${NC}"
    fi
}

# Function to chat with a waifu
chat_with_waifu() {
    if [ "$#" -lt 1 ]; then
        echo -e "${RED}Error: Please specify a waifu name to chat with.${NC}"
        echo -e "Usage: waifu-bot chat <name>"
        return 1
    fi
    
    waifu_name="$1"
    shift
    
    waifu_file="$CHATBOT_CONFIG_DIR/$waifu_name.conf"
    
    if [ ! -f "$waifu_file" ]; then
        echo -e "${RED}Error: Waifu '$waifu_name' not found.${NC}"
        echo -e "Create one with: ${CYAN}waifu-bot create${NC}"
        return 1
    fi
    
    # Check if API key is set
    check_api_key || return 1
    
    # Source the waifu configuration
    source "$waifu_file"
    
    echo -e "${CYAN}======== Chatting with $WAIFU_NAME ========${NC}"
    echo -e "${YELLOW}Type 'exit' to end the conversation.${NC}"
    
    # Prepare the system prompt
    system_prompt="You are $WAIFU_NAME, an anime character with the following traits: $WAIFU_PERSONALITY. $WAIFU_TRAITS You're chatting with $USER_NAME who you care about. Respond as your character would, keeping responses fairly brief and casual. Use some Japanese expressions occasionally if appropriate for your character."
    
    # Start the chat loop
    while true; do
        # Get user input
        read -e -p "${GREEN}You:${NC} " user_input
        
        # Check if user wants to exit
        if [ "$user_input" = "exit" ]; then
            echo -e "${CYAN}$WAIFU_NAME waves goodbye!${NC}"
            break
        fi
        
        # Skip empty inputs
        if [ -z "$user_input" ]; then
            continue
        fi
        
        echo -e "${YELLOW}$WAIFU_NAME is typing...${NC}"
        
        # Call the OpenAI API
        response=$(curl -s https://api.openai.com/v1/chat/completions \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $OPENAI_API_KEY" \
            -d '{
                "model": "gpt-3.5-turbo",
                "messages": [
                    {"role": "system", "content": "'"$system_prompt"'"},
                    {"role": "user", "content": "'"$user_input"'"}
                ],
                "temperature": 0.7,
                "max_tokens": 150
            }')
        
        # Check if the API call was successful
        if [ $? -ne 0 ]; then
            echo -e "${RED}Error: Failed to connect to OpenAI API.${NC}"
            echo -e "Please check your internet connection and try again."
            continue
        fi
        
        # Parse the response
        if ! echo "$response" | jq -e '.choices[0].message.content' &>/dev/null; then
            error_message=$(echo "$response" | jq -r '.error.message // "Unknown error"')
            echo -e "${RED}API Error: $error_message${NC}"
            continue
        fi
        
        # Extract and display the waifu's response
        waifu_response=$(echo "$response" | jq -r '.choices[0].message.content')
        echo -e "${PURPLE}$WAIFU_NAME:${NC} $waifu_response"
    done
}

# Main function
if [ "$#" -eq 0 ]; then
    show_help
    exit 0
fi

command="$1"
shift

case "$command" in
    "create")
        create_waifu
        ;;
    "list")
        list_waifus
        ;;
    "chat")
        chat_with_waifu "$@"
        ;;
    "delete")
        delete_waifu "$@"
        ;;
    "setkey")
        set_api_key
        ;;
    "help")
        show_help
        ;;
    *)
        echo -e "${RED}Error: Unknown command: $command${NC}"
        show_help
        exit 1
        ;;
esac

exit 0