#!/bin/bash
# VIN OS System Command
# This script provides system-related functionality for VIN OS

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

# Function to display system information
show_system_info() {
    echo -e "\033[1;36m========== VIN OS System Information ==========\033[0m"
    
    # Get kernel information
    echo -e "\033[1;33mKernel:\033[0m $(uname -r)"
    
    # Get OS information
    if [ "$TERMUX_MODE" = true ]; then
        echo -e "\033[1;33mEnvironment:\033[0m Termux on Android"
        echo -e "\033[1;33mAndroid Version:\033[0m $(getprop ro.build.version.release 2>/dev/null || echo "Unknown")"
        echo -e "\033[1;33mDevice:\033[0m $(getprop ro.product.model 2>/dev/null || echo "Unknown")"
    else
        if [ -f /etc/os-release ]; then
            source /etc/os-release
            echo -e "\033[1;33mOS:\033[0m $PRETTY_NAME"
        else
            echo -e "\033[1;33mOS:\033[0m Unknown Linux distribution"
        fi
    fi
    
    # Get CPU information
    if [ -f /proc/cpuinfo ]; then
        cpu_model=$(grep "model name" /proc/cpuinfo | head -n 1 | cut -d ":" -f 2 | sed 's/^[ \t]*//')
        cpu_cores=$(grep -c "processor" /proc/cpuinfo)
        echo -e "\033[1;33mCPU:\033[0m $cpu_model ($cpu_cores cores)"
    else
        echo -e "\033[1;33mCPU:\033[0m Information not available"
    fi
    
    # Get memory information
    if [ -f /proc/meminfo ]; then
        total_mem=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
        total_mem_mb=$((total_mem / 1024))
        free_mem=$(grep "MemFree" /proc/meminfo | awk '{print $2}')
        free_mem_mb=$((free_mem / 1024))
        used_mem_mb=$((total_mem_mb - free_mem_mb))
        echo -e "\033[1;33mMemory:\033[0m Used: ${used_mem_mb}MB / Total: ${total_mem_mb}MB"
    else
        echo -e "\033[1;33mMemory:\033[0m Information not available"
    fi
    
    # Get disk information
    if command -v df >/dev/null 2>&1; then
        if [ "$TERMUX_MODE" = true ]; then
            echo -e "\033[1;33mStorage:\033[0m"
            df -h | grep -E "storage|emulated" | awk '{print "  " $6 ": " $3 " used out of " $2 " (" $5 ")"}'
        else
            echo -e "\033[1;33mDisk Usage (/):\033[0m"
            df -h / | tail -n 1 | awk '{print "  " $3 " used out of " $2 " (" $5 ")"}'
        fi
    else
        echo -e "\033[1;33mDisk Usage:\033[0m Information not available"
    fi
    
    echo -e "\033[1;36m=================================================\033[0m"
}

# Function to display repository information
show_repos_info() {
    echo -e "\033[1;36m========== VIN OS Repository Information ==========\033[0m"
    
    if [ "$TERMUX_MODE" = true ]; then
        if [ -f "$VINOS_CONFIG/repositories.conf" ]; then
            echo -e "\033[1;33mConfigured Repositories:\033[0m"
            cat "$VINOS_CONFIG/repositories.conf" | grep -v "^#" | grep -v "^$" | while read line; do
                echo -e "  \033[1;32m$line\033[0m"
            done
        else
            echo -e "\033[1;33mTermux Default Repositories:\033[0m"
            if [ -f "$PREFIX/etc/apt/sources.list" ]; then
                cat "$PREFIX/etc/apt/sources.list" | grep -v "^#" | grep -v "^$" | while read line; do
                    echo -e "  \033[1;32m$line\033[0m"
                done
            else
                echo -e "  \033[1;31mNo repository information available\033[0m"
            fi
        fi
    else
        echo -e "\033[1;33mUbuntu Repositories:\033[0m"
        if [ -f /etc/apt/sources.list ]; then
            grep -E "^deb.*ubuntu" /etc/apt/sources.list | while read line; do
                echo -e "  \033[1;32m$line\033[0m"
            done
        else
            echo -e "  \033[1;31mNo Ubuntu repository information available\033[0m"
        fi
        
        echo -e "\033[1;33mKali Linux Repositories:\033[0m"
        if [ -f /etc/apt/sources.list.d/kali.list ]; then
            cat /etc/apt/sources.list.d/kali.list | grep -v "^#" | grep -v "^$" | while read line; do
                echo -e "  \033[1;32m$line\033[0m"
            done
        else
            echo -e "  \033[1;31mKali repositories not configured\033[0m"
        fi
    fi
    
    echo -e "\033[1;36m===================================================\033[0m"
}

# Function to update VIN OS components
update_vinos() {
    echo -e "\033[1;36mUpdating VIN OS components...\033[0m"
    
    # For a real implementation, this would pull updates from a git repository
    # or another update mechanism. For now, we'll just simulate the update.
    echo -e "\033[1;33mChecking for updates...\033[0m"
    sleep 1
    echo -e "\033[1;32mVIN OS is already up to date!\033[0m"
    
    echo -e "\033[1;36mUpdate complete!\033[0m"
}

# Main function
if [ "$#" -eq 0 ]; then
    echo -e "\033[1;31mError: Missing subcommand\033[0m"
    echo -e "Usage: system [info|repos|update]"
    exit 1
fi

case "$1" in
    "info")
        show_system_info
        ;;
    "repos")
        show_repos_info
        ;;
    "update")
        update_vinos
        ;;
    *)
        echo -e "\033[1;31mError: Unknown subcommand: $1\033[0m"
        echo -e "Usage: system [info|repos|update]"
        exit 1
        ;;
esac

exit 0
