```bash
#!/bin/bash
################################################################################
# Docker Diagnose & Fix Tool
# - Detects container conflicts (name already in use)
# - Diagnoses container health, logs, network & volume issues
# - Provides safe automated fixes
# - Works with Docker + Docker Compose
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}============================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

ok()   { echo -e "${GREEN}✓ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠ $1${NC}"; }
err()  { echo -e "${RED}✗ $1${NC}"; }
info() { echo -e "${BLUE}ℹ $1${NC}"; }

################################################################################
# Check Docker availability
################################################################################
check_docker() {
    print_header "STEP 1: Checking Docker Engine"

    if ! command -v docker &>/dev/null; then
        err "Docker CLI not installed."
        exit 1
    fi

    if ! docker info &>/dev/null; then
        err "Docker daemon is NOT running."
        warn "Start Docker Desktop or systemctl start docker"
        exit 1
    fi

    ok "Docker daemon is running."
}

################################################################################
# Diagnose container issues
################################################################################
diagnose_containers() {
    print_header "STEP 2: Analyzing Container Health"

    info "Running containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}"

    info "Stopped / failed containers:"
    docker ps -a | grep -E "Exited|Created|Dead|Restarting" || ok "No unhealthy containers found."

    # Track summary
    UNHEALTHY_COUNT=$(docker ps -a | grep -E "Exited|Created|Dead|Restarting" | wc -l)

    if [[ "$UNHEALTHY_COUNT" -gt 0 ]]; then
        warn "$UNHEALTHY_COUNT unhealthy containers detected."
    fi
}

################################################################################
# Fix container-name conflicts
################################################################################
fix_name_conflicts() {
    print_header "STEP 3: Detecting Name Conflicts"

    CONFLICTING=$(docker ps -a --format '{{.Names}}' | grep -E "grafana-server|prometheus-server|config-server|tracing-server")

    if [[ -z "$CONFLICTING" ]]; then
        ok "No container name conflicts detected."
        return
    fi

    warn "Found conflicting containers:"
    echo "$CONFLICTING"

    echo ""
    echo "Choose an action:"
    echo "1) Remove conflicting containers"
    echo "2) Force remove (kill + delete)"
    echo "3) Rename them automatically"
    echo "4) Skip"
    read -rp "Your choice: " CHOICE

    case "$CHOICE" in
        1)
            for c in $CONFLICTING; do
                info "Removing $c..."
                docker rm "$c" && ok "Removed $c"
            done
            ;;
        2)
            for c in $CONFLICTING; do
                info "Force removing $c..."
                docker rm -f "$c" && ok "Force removed $c"
            done
            ;;
        3)
            for c in $CONFLICTING; do
                NEW="${c}-old-$(date +%s)"
                info "Renaming $c → $NEW"
                docker rename "$c" "$NEW" && ok "Renamed to $NEW"
            done
            ;;
        *)
            warn "Skipping conflict resolution."
            ;;
    esac
}

################################################################################
# Inspect container logs for errors
################################################################################
container_logs_check() {
    print_header "STEP 4: Checking Logs for Errors"

    UNHEALTHY=$(docker ps -a --format '{{.Names}} {{.State}} {{.Status}}' | grep -E "Exited|Restarting|Dead" | awk '{print $1}')

    if [[ -z "$UNHEALTHY" ]]; then
        ok "No log issues detected."
        return
    fi

    warn "Containers with problems detected:"
    echo "$UNHEALTHY"

    for c in $UNHEALTHY; do
        info "Last 20 logs for $c:"
        docker logs --tail 20 "$c" 2>&1 | sed 's/^/  /'
        echo ""
    done
}

################################################################################
# Diagnose volumes, networks, and images
################################################################################
deep_diagnose() {
    print_header "STEP 5: Volume, Network & Image Diagnostics"

    info "Docker volumes:"
    docker volume ls

    info "Docker networks:"
    docker network ls

    info "Dangling images:"
    docker images -f "dangling=true"
}

################################################################################
# Optional cleanup tools
################################################################################
cleanup_menu() {
    print_header "STEP 6: Optional Cleanup Tools"

    echo "Choose a cleanup option:"
    echo "1) Remove ALL stopped containers"
    echo "2) Remove ALL unused volumes"
    echo "3) Remove ALL unused images"
    echo "4) Run full prune (containers + volumes + networks + images)"
    echo "5) Skip"
    read -rp "Your choice: " CLEAN

    case "$CLEAN" in
        1) docker container prune -f && ok "Stopped containers removed." ;;
        2) docker volume prune -f && ok "Unused volumes removed." ;;
        3) docker image prune -f && ok "Unused images removed." ;;
        4) docker system prune -af && ok "Full prune completed." ;;
        *) warn "Skipped cleanup."; ;;
    esac
}

################################################################################
# Summary
################################################################################
summary() {
    print_header "SUMMARY"

    echo -e "${GREEN}✓ Docker checked${NC}"
    echo -e "${GREEN}✓ Containers analyzed${NC}"
    echo -e "${GREEN}✓ Name conflicts resolved (if selected)${NC}"
    echo -e "${GREEN}✓ Logs inspected${NC}"
    echo -e "${GREEN}✓ Volume/network diagnostics completed${NC}"
    echo -e "${GREEN}✓ Optional cleanup executed${NC}"

    echo ""
    info "Script completed."
}

################################################################################
# Main
################################################################################
main() {
    check_docker
    diagnose_containers
    fix_name_conflicts
    container_logs_check
    deep_diagnose
    cleanup_menu
    summary
}

main

```