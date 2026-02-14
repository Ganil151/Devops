#!/bin/bash

################################################################################
# Browser Security Service Manager
# Purpose: Interactive menu to manage Python and Shell security services.
# Path: /home/gsmash/Documents/Devops/07-boilerplates/04-playground/block-popups/manage-services.sh
################################################################################

# ============================================================================
# CONFIGURATION
# ============================================================================
BASE_DIR="/home/gsmash/Documents/Devops/07-boilerplates/04-playground/block-popups"
PYTHON_SCRIPT="${BASE_DIR}/block-popups.py"
SHELL_SCRIPT="${BASE_DIR}/block-popups.sh"

PYTHON_PID_FILE="${BASE_DIR}/.python-service.pid"
SHELL_PID_FILE="${BASE_DIR}/.shell-service.pid"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================================
# GUARDS & CHECKS
# ============================================================================

check_root() {
    if [[ $EUID -ne 0 ]]; then
       echo -e "${RED}[!] Error: This script must be run as root (sudo).${NC}"
       exit 1
    fi
}

check_dependencies() {
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}[!] Error: python3 is not installed.${NC}"
        return 1
    fi
    return 0
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

get_status() {
    local pattern="$1"
    if pgrep -f "$pattern" > /dev/null; then
        echo -e "${GREEN}ACTIVE${NC}"
    else
        echo -e "${RED}INACTIVE${NC}"
    fi
}

start_service() {
    local name="$1"
    local script="$2"
    local pid_file="$3"
    local runner="$4"

    if pgrep -f "$script" > /dev/null; then
        echo -e "${YELLOW}[!] $name is already running.${NC}"
        return
    fi

    echo -en "${BLUE}[*] Launching $name... ${NC}"
    nohup $runner "$script" > "${BASE_DIR}/${name,,}.log" 2>&1 &
    local pid=$!
    echo $pid > "$pid_file"
    
    sleep 1
    if ps -p $pid > /dev/null; then
        echo -e "${GREEN}SUCCESS (PID: $pid)${NC}"
    else
        echo -e "${RED}FAILED${NC}"
        rm -f "$pid_file"
    fi
}

stop_service() {
    local name="$1"
    local script="$2"
    local pid_file="$3"

    if [[ -f "$pid_file" ]]; then
        local pid=$(cat "$pid_file")
        echo -en "${BLUE}[*] Terminating $name (PID: $pid)... ${NC}"
        kill "$pid" 2>/dev/null
        rm -f "$pid_file"
        echo -e "${GREEN}DONE${NC}"
    else
        local pids=$(pgrep -f "$script")
        if [[ -n "$pids" ]]; then
            echo -en "${BLUE}[*] Killing $name via pgrep... ${NC}"
            kill $pids 2>/dev/null
            echo -e "${GREEN}DONE${NC}"
        else
            echo -e "${YELLOW}[!] $name is not currently running.${NC}"
        fi
    fi
}

# ============================================================================
# MAIN MENU
# ============================================================================

show_menu() {
    clear
    echo -e "${BLUE}==================================================${NC}"
    echo -e "      🛡️  BROWSER SECURITY CONTROL CENTER  🛡️"
    echo -e "${BLUE}==================================================${NC}"
    echo ""
    echo -e "1) Python Service  - Status: $(get_status "$PYTHON_SCRIPT")"
    echo -e "2) Shell Service   - Status: $(get_status "$SHELL_SCRIPT")"
    echo ""
    echo -e "${YELLOW}Manage Python Blockers:${NC}"
    echo -e "  [p] Start Service"
    echo -e "  [k] Stop Service"
    echo ""
    echo -e "${YELLOW}Manage Shell Blockers:${NC}"
    echo -e "  [s] Start Service"
    echo -e "  [x] Stop Service"
    echo ""
    echo -e "${YELLOW}Batch Actions:${NC}"
    echo -e "  [a] Enable All Services"
    echo -e "  [r] Disable All Services"
    echo ""
    echo -e "  [q] Exit"
    echo ""
    echo -e "${BLUE}==================================================${NC}"
    echo -n "Action: "
}

check_root

while true; do
    show_menu
    read -r opt
    case $opt in
        1|p)
            if check_dependencies; then
                start_service "Python" "$PYTHON_SCRIPT" "$PYTHON_PID_FILE" "python3"
            fi
            read -p "Press enter to continue..."
            ;;
        2|s)
            start_service "Shell" "$SHELL_SCRIPT" "$SHELL_PID_FILE" "bash"
            read -p "Press enter to continue..."
            ;;
        k)
            stop_service "Python" "$PYTHON_SCRIPT" "$PYTHON_PID_FILE"
            read -p "Press enter to continue..."
            ;;
        x)
            stop_service "Shell" "$SHELL_SCRIPT" "$SHELL_PID_FILE"
            read -p "Press enter to continue..."
            ;;
        a)
            echo -e "${BLUE}[*] Batch Start...${NC}"
            if check_dependencies; then
                start_service "Python" "$PYTHON_SCRIPT" "$PYTHON_PID_FILE" "python3"
            fi
            start_service "Shell" "$SHELL_SCRIPT" "$SHELL_PID_FILE" "bash"
            read -p "Press enter to continue..."
            ;;
        r)
            echo -e "${RED}[*] Batch Stop...${NC}"
            stop_service "Python" "$PYTHON_SCRIPT" "$PYTHON_PID_FILE"
            stop_service "Shell" "$SHELL_SCRIPT" "$SHELL_PID_FILE"
            read -p "Press enter to continue..."
            ;;
        q)
            echo -n "Would you like to stop all services before exiting? (y/n): "
            read -r stop_all
            if [[ "$stop_all" =~ ^[Yy]$ ]]; then
                stop_service "Python" "$PYTHON_SCRIPT" "$PYTHON_PID_FILE"
                stop_service "Shell" "$SHELL_SCRIPT" "$SHELL_PID_FILE"
                echo -e "${GREEN}Services stopped. Cleanup complete.${NC}"
            fi
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo -e "${RED}[!] Invalid option.${NC}"
            sleep 1
            ;;
    esac
done
