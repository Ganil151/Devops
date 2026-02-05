#!/bin/bash
# Quick Reference Script for project_clean.py
# This script provides common usage patterns for the cleanup utility

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLEANUP_SCRIPT="$SCRIPT_DIR/project_clean.py"

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Project Cleanup Utility - Quick Reference             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to display a command example
show_example() {
    local title="$1"
    local command="$2"
    echo -e "${GREEN}▶ $title${NC}"
    echo -e "  ${YELLOW}$command${NC}"
    echo ""
}

# Display common usage patterns
show_example "1. Audit current directory (safe preview)" \
    "python3 $CLEANUP_SCRIPT"

show_example "2. Audit specific directory" \
    "python3 $CLEANUP_SCRIPT -d /path/to/project"

show_example "3. Audit with recursive search" \
    "python3 $CLEANUP_SCRIPT -d /path/to/project -r"

show_example "4. Audit with verbose output" \
    "python3 $CLEANUP_SCRIPT -d /path/to/project -r -v"

show_example "5. Execute cleanup (CAUTION: deletes files)" \
    "python3 $CLEANUP_SCRIPT -d /path/to/project --execute"

show_example "6. Execute cleanup with backup" \
    "python3 $CLEANUP_SCRIPT -d /path/to/project --execute --backup ./backups"

show_example "7. Clean specific file patterns" \
    "python3 $CLEANUP_SCRIPT -d /path/to/project -p '*.tmp' '*.log' --execute"

show_example "8. Recursive cleanup with backup and verbose logging" \
    "python3 $CLEANUP_SCRIPT -d /path/to/project -r --execute --backup ~/backups/\$(date +%Y%m%d) -v"

show_example "9. Clean DevOps directory recursively (default patterns)" \
    "python3 $CLEANUP_SCRIPT -d ~/Documents/Devops -r --execute --backup ~/backups/devops_\$(date +%Y%m%d_%H%M%S)"

show_example "10. Show help and all options" \
    "python3 $CLEANUP_SCRIPT --help"

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}⚠️  SAFETY TIPS:${NC}"
echo "  • Always run in audit mode first (without --execute)"
echo "  • Use --backup flag when deleting important files"
echo "  • Use -v (verbose) to see detailed operation logs"
echo "  • Test with a small directory first"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
