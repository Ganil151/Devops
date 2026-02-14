#!/bin/bash

################################################################################
# Service Management Control Tower
# Located at: /home/gsmash/Documents/Devops/07-boilerplates/04-playground/block-popups/manage-services.sh
# Purpose: Interactive menu to manage Python and Shell security services.
################################################################################

# ============================================================================
# BASE CONFIGURATION
# ============================================================================
BASE_DIR="/home/gsmash/Documents/Devops/07-boilerplates/04-playground/block-popups"
PYTHON_SCRIPT="${BASE_DIR}/block-popups.py"
SHELL_SCRIPT="${BASE_DIR}/block-popups.sh"

PYTHON_PID_FILE="${BASE_DIR}/.python-service.pid"
SHELL_PID_FILE="${BASE_DIR}/.shell-service.pid"

# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# SAFETY & PRE-FLIGHT CHECKS
# ============================================================================

check_root() {
    if [[ $EUID -ne 0 ]]; then
       echo -e "${RED}[!] ERROR: This script must be run as root/sudo because the underlying services modify system files.${NC}"
       exit 1
    fi
}

check_dependencies() {
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}[!] ERROR: python3 is not installed. Python service cannot start.${NC}"
        return 1
    fi
    return 0
}

# ============================================================================
# SERVICE MANAGEMENT FUNCTIONS
# ============================================================================

get_status() {
    local cmd_pattern="$1"
    # use pgrep -f to match the full command line
    if pgrep -f "$cmd_pattern" > /dev/null; then
        echo -e "${GREEN}RUNNING${NC}"
    else
        echo -e "${RED}STOPPED${NC}"
    fi
}

start_service() {
    local name="$1"
    local script="$2"
    local pid_file="$3"
    local run_cmd="$4"

    if pgrep -f "$script" > /dev/null; then
        echo -e "${YELLOW}[!] Warning: $name is already running.${NC}"
        return
    fi

    echo -en "${BLUE}[*] Starting $name...${NC} "
    nohup $run_cmd "$script" > "${BASE_DIR}/${name,,}.log" 2>&1 &
    local pid=$!
    echo $pid > "$pid_file"
    
    # Give it a second to initialize and check if it actually stayed up
    sleep 1
    if ps -p $pid > /dev/null; then
        echo -e "${GREEN}DONE (PID: $pid)${NC}"
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
        echo -en "${BLUE}[*] Stopping $name (PID: $pid)...${NC} "
        kill "$pid" 2>/dev/null
        rm -f "$pid_file"
        echo -e "${GREEN}DONE${NC}"
    else
        # Fallback to pgrep if pid file is lost
        local pids=$(pgrep -f "$script")
        if [[ -n "$pids" ]]; then
            echo -en "${BLUE}[*] Stopping $name processes found via pgrep...${NC} "
            kill $pids 2>/dev/null
            echo -e "${GREEN}DONE${NC}"
        else
            echo -e "${YELLOW}[!] Warning: $name is not running.${NC}"
        fi
    fi
}

# ============================================================================
# INTERACTIVE MENU
# ============================================================================

draw_menu() {
    clear
    echo -e "${BLUE}====================================================${NC}"
    echo -e "   🛡️  BROWSER SECURITY CONTROL TOWER   🛡️"
    echo -e "${BLUE}====================================================${NC}"
    echo ""
    echo -e "1) Python Service:  $(get_status "$PYTHON_SCRIPT")"
    echo -e "2) Shell Service:   $(get_status "$SHELL_SCRIPT")"
    echo ""
    echo -e "${YELLOW}--- PYTHON ACTIONS ---${NC}"
    echo -e "  p) [START] Python Service"
    echo -e "  k) [STOP]  Python Service"
    echo ""
    echo -e "${YELLOW}--- SHELL ACTIONS ---${NC}"
    echo -e "  s) [START] Shell Service"
    echo -e "  x) [STOP]  Shell Service"
    echo ""
    echo -e "${YELLOW}--- BATCH ACTIONS ---${NC}"
    echo -e "  a) [START] Enable All"
    echo -e "  r) [STOP]  Disable All"
    echo ""
    echo -e "q) EXIT CONTROL TOWER"
    echo ""
    echo -e "${BLUE}====================================================${NC}"
    echo -n "Select an option: "
}

# Ensure root privileges before starting
check_root

while true; do
    draw_menu
    read choice

    case $choice in
        1|p)
            if check_dependencies; then
                start_service "Python-Service" "$PYTHON_SCRIPT" "$PYTHON_PID_FILE" "python3"
            fi
            read -n 1 -s -p "Press any key to return to menu..."
            ;;
        2|s)
            start_service "Shell-Service" "$SHELL_SCRIPT" "$SHELL_PID_FILE" "bash"
            read -n 1 -s -p "Press any key to return to menu..."
            ;;
        k)
            stop_service "Python-Service" "$PYTHON_SCRIPT" "$PYTHON_PID_FILE"
            read -n 1 -s -p "Press any key to return to menu..."
            ;;
        x)
            stop_service "Shell-Service" "$SHELL_SCRIPT" "$SHELL_PID_FILE"
            read -n 1 -s -p "Press any key to return to menu..."
            ;;
        a)
            echo -e "${BLUE}[*] Batch Operation: Enabling All Services...${NC}"
            if check_dependencies; then
                start_service "Python-Service" "$PYTHON_SCRIPT" "$PYTHON_PID_FILE" "python3"
            fi
            start_service "Shell-Service" "$SHELL_SCRIPT" "$SHELL_PID_FILE" "bash"
            echo -e "${GREEN}[✓] Operation Complete.${NC}"
            read -n 1 -s -p "Press any key to return to menu..."
            ;;
        r)
            echo -e "${RED}[*] Batch Operation: Disabling All Services...${NC}"
            stop_service "Python-Service" "$PYTHON_SCRIPT" "$PYTHON_PID_FILE"
            stop_service "Shell-Service" "$SHELL_SCRIPT" "$SHELL_PID_FILE"
            echo -e "${YELLOW}[✓] Operation Complete.${NC}"
            read -n 1 -s -p "Press any key to return to menu..."
            ;;
        q)
            echo -n "Stop all services before exiting? (y/n): "
            read stop_all
            if [[ "$stop_all" =~ ^[Yy]$ ]]; then
                stop_service "Python-Service" "$PYTHON_SCRIPT" "$PYTHON_PID_FILE"
                stop_service "Shell-Service" "$SHELL_SCRIPT" "$SHELL_PID_FILE"
                echo -e "${GREEN}[✓] Cleanup finished. Goodbye!${NC}"
            else
                echo -e "${YELLOW}[!] Exiting without cleanup. Services remain active.${NC}"
            fi
            exit 0
            ;;
        *)
            echo -e "${RED}[!] Invalid choice. Please try again.${NC}"
            sleep 1
            ;;
    esac
done
