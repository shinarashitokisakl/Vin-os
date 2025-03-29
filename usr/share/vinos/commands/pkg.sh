#!/bin/bash
# VIN OS Package Management Command
# This script provides package management functionality for VIN OS

# Set current directory to the script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Check if we're running in Termux
if [ -d "/data/data/com.termux/files/usr" ]; then
    export VINOS_DIR="/data/data/com.termux/files/usr/share/vinos"
    export VINOS_CONFIG="/data/data/com.termux/files/usr/etc/vinos"
    export TERMUX_MODE=true
    export PKG_CMD="pkg"
else
    export VINOS_DIR="$BASE_DIR/usr/share/vinos"
    export VINOS_CONFIG="$BASE_DIR/etc/vinos"
    export TERMUX_MODE=false
    export PKG_CMD="apt"
fi

# Function to update package lists
update_packages() {
    echo -e "\033[1;36mUpdating package lists...\033[0m"
    
    if [ "$TERMUX_MODE" = true ]; then
        $PKG_CMD update
    else
        sudo $PKG_CMD update
    fi
    
    echo -e "\033[1;36mPackage lists updated.\033[0m"
}

# Function to install packages
install_packages() {
    if [ "$#" -eq 0 ]; then
        echo -e "\033[1;31mError: No packages specified\033[0m"
        echo -e "Usage: install [package1] [package2] ..."
        return 1
    fi
    
    echo -e "\033[1;36mInstalling packages: $(echo "$@")\033[0m"
    
    if [ "$TERMUX_MODE" = true ]; then
        $PKG_CMD install -y "$@"
    else
        sudo $PKG_CMD install -y "$@"
    fi
    
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo -e "\033[1;32mPackages installed successfully.\033[0m"
    else
        echo -e "\033[1;31mFailed to install packages. Exit code: $exit_code\033[0m"
    fi
}

# Function to remove packages
remove_packages() {
    if [ "$#" -eq 0 ]; then
        echo -e "\033[1;31mError: No packages specified\033[0m"
        echo -e "Usage: remove [package1] [package2] ..."
        return 1
    fi
    
    echo -e "\033[1;36mRemoving packages: $(echo "$@")\033[0m"
    
    if [ "$TERMUX_MODE" = true ]; then
        $PKG_CMD uninstall -y "$@"
    else
        sudo $PKG_CMD remove -y "$@"
    fi
    
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo -e "\033[1;32mPackages removed successfully.\033[0m"
    else
        echo -e "\033[1;31mFailed to remove packages. Exit code: $exit_code\033[0m"
    fi
}

# Main function
if [ "$#" -eq 0 ]; then
    echo -e "\033[1;31mError: Missing subcommand\033[0m"
    echo -e "Usage: pkg [update|install|remove] [packages...]"
    exit 1
fi

command="$1"
shift

case "$command" in
    "update")
        update_packages
        ;;
    "install")
        install_packages "$@"
        ;;
    "remove")
        remove_packages "$@"
        ;;
    *)
        echo -e "\033[1;31mError: Unknown subcommand: $command\033[0m"
        echo -e "Usage: pkg [update|install|remove] [packages...]"
        exit 1
        ;;
esac

exit 0
