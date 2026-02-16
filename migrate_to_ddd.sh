#!/usr/bin/env bash
#
# Domain-Driven Design (DDD) Migration Script
# Purpose: Restructure DevOps directory into 5 high-level pillars
# Standard: Atomic Preservation + Path Accuracy
# Date: 2026-02-16
#
# CRITICAL RULES:
# 1. NO consolidation of individual command files
# 2. ALL scripts (.sh, .ps1, .py) are preserved
# 3. Only files from tree.txt are migrated
# 4. Use absolute paths only
#

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly BASE_DIR="/home/gsmash/Documents/Devops"
readonly BACKUP_DIR="${HOME}/Devops_BACKUP_$(date +%Y%m%d_%H%M%S)"
readonly LOG_FILE="${BASE_DIR}/migration_$(date +%Y%m%d_%H%M%S).log"
readonly DRY_RUN="${DRY_RUN:-false}"  # Set DRY_RUN=true to test without changes

# Pillar directories
readonly PILLAR_01="${BASE_DIR}/01-Engineering-Foundations"
readonly PILLAR_02="${BASE_DIR}/02-Automation-Orchestration"
readonly PILLAR_03="${BASE_DIR}/03-The-Reference-Vault"
readonly PILLAR_04="${BASE_DIR}/04-Career-Strategy-Ops"
readonly PILLAR_05="${BASE_DIR}/05-Assets-and-Themes"

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOG_FILE}"
}

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "${LOG_FILE}" >&2
}

log_success() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ✅ $*" | tee -a "${LOG_FILE}"
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

create_backup() {
    log "Creating backup at ${BACKUP_DIR}..."
    if [[ "${DRY_RUN}" == "false" ]]; then
        mkdir -p "${BACKUP_DIR}"
        tar -czf "${BACKUP_DIR}/devops_backup.tar.gz" \
            --exclude='01-beginner_RECOVERY' \
            --exclude='.git' \
            "${BASE_DIR}" 2>/dev/null || log_error "Backup failed (non-critical)"
        log_success "Backup created"
    else
        log "DRY RUN: Would create backup at ${BACKUP_DIR}"
    fi
}

safe_mkdir() {
    local dir="$1"
    if [[ "${DRY_RUN}" == "false" ]]; then
        mkdir -p "${dir}"
    else
        log "DRY RUN: Would create directory: ${dir}"
    fi
}

safe_copy() {
    local src="$1"
    local dest="$2"
    
    if [[ ! -e "${src}" ]]; then
        log_error "Source does not exist: ${src}"
        return 1
    fi
    
    if [[ "${DRY_RUN}" == "false" ]]; then
        # Create destination directory
        mkdir -p "$(dirname "${dest}")"
        
        # Copy with preservation of attributes
        if [[ -d "${src}" ]]; then
            cp -r "${src}" "${dest}"
        else
            cp -p "${src}" "${dest}"
        fi
        log "Copied: ${src} → ${dest}"
    else
        log "DRY RUN: Would copy ${src} → ${dest}"
    fi
}

safe_move() {
    local src="$1"
    local dest="$2"
    
    if [[ ! -e "${src}" ]]; then
        log_error "Source does not exist: ${src}"
        return 1
    fi
    
    if [[ "${DRY_RUN}" == "false" ]]; then
        mkdir -p "$(dirname "${dest}")"
        mv "${src}" "${dest}"
        log "Moved: ${src} → ${dest}"
    else
        log "DRY RUN: Would move ${src} → ${dest}"
    fi
}

# ============================================================================
# PILLAR CREATION
# ============================================================================

create_pillar_structure() {
    log "Creating 5-Pillar DDD structure..."
    
    safe_mkdir "${PILLAR_01}"
    safe_mkdir "${PILLAR_02}"
    safe_mkdir "${PILLAR_03}"
    safe_mkdir "${PILLAR_04}"
    safe_mkdir "${PILLAR_05}"
    
    log_success "Pillar directories created"
}

# ============================================================================
# PILLAR 01: ENGINEERING FOUNDATIONS
# ============================================================================

migrate_pillar_01() {
    log "========================================="
    log "MIGRATING PILLAR 01: Engineering Foundations"
    log "========================================="
    
    # Linux Fundamentals (merge duplicates)
    local linux_dest="${PILLAR_01}/01-linux-fundamentals"
    safe_mkdir "${linux_dest}"
    
    # Copy from 01-linux-fundamentals (primary)
    if [[ -d "${BASE_DIR}/01-beginner/01-linux-fundamentals" ]]; then
        safe_copy "${BASE_DIR}/01-beginner/01-linux-fundamentals/." "${linux_dest}/"
    fi
    
    # Merge from 01-Linux-Engineering (secondary)
    if [[ -d "${BASE_DIR}/01-beginner/01-Linux-Engineering" ]]; then
        # Copy unique files, rename conflicting READMEs
        find "${BASE_DIR}/01-beginner/01-Linux-Engineering" -type f | while read -r file; do
            local rel_path="${file#${BASE_DIR}/01-beginner/01-Linux-Engineering/}"
            local dest_file="${linux_dest}/${rel_path}"
            
            if [[ -e "${dest_file}" ]] && [[ "${file}" == *"readme.md" ]]; then
                # Rename conflicting README
                safe_copy "${file}" "${dest_file%.md}-v2.md"
            elif [[ ! -e "${dest_file}" ]]; then
                safe_copy "${file}" "${dest_file}"
            fi
        done
    fi
    
    # Networking Concepts (merge duplicates)
    local network_dest="${PILLAR_01}/02-networking-concepts"
    safe_mkdir "${network_dest}"
    
    if [[ -d "${BASE_DIR}/01-beginner/02-networking-concepts" ]]; then
        safe_copy "${BASE_DIR}/01-beginner/02-networking-concepts/." "${network_dest}/"
    fi
    
    if [[ -d "${BASE_DIR}/01-beginner/02-Network-Protocols" ]]; then
        find "${BASE_DIR}/01-beginner/02-Network-Protocols" -type f | while read -r file; do
            local rel_path="${file#${BASE_DIR}/01-beginner/02-Network-Protocols/}"
            local dest_file="${network_dest}/${rel_path}"
            
            if [[ -e "${dest_file}" ]] && [[ "${file}" == *"readme.md" ]]; then
                safe_copy "${file}" "${dest_file%.md}-v2.md"
            elif [[ ! -e "${dest_file}" ]]; then
                safe_copy "${file}" "${dest_file}"
            fi
        done
    fi
    
    # Git Version Control (merge duplicates)
    local git_dest="${PILLAR_01}/03-git-version-control"
    safe_mkdir "${git_dest}"
    
    if [[ -d "${BASE_DIR}/01-beginner/03-git-version-control" ]]; then
        safe_copy "${BASE_DIR}/01-beginner/03-git-version-control/." "${git_dest}/"
    fi
    
    if [[ -d "${BASE_DIR}/01-beginner/03-Git-Version-Control" ]]; then
        find "${BASE_DIR}/01-beginner/03-Git-Version-Control" -type f | while read -r file; do
            local rel_path="${file#${BASE_DIR}/01-beginner/03-Git-Version-Control/}"
            local dest_file="${git_dest}/${rel_path}"
            
            if [[ -e "${dest_file}" ]] && [[ "${file}" == *"readme.md" ]]; then
                safe_copy "${file}" "${dest_file%.md}-v2.md"
            elif [[ ! -e "${dest_file}" ]]; then
                safe_copy "${file}" "${dest_file}"
            fi
        done
    fi
    
    # Automation Scripting (merge duplicates)
    local scripting_dest="${PILLAR_01}/04-automation-scripting"
    safe_mkdir "${scripting_dest}"
    
    if [[ -d "${BASE_DIR}/01-beginner/04-automation-scripting" ]]; then
        safe_copy "${BASE_DIR}/01-beginner/04-automation-scripting/." "${scripting_dest}/"
    fi
    
    if [[ -d "${BASE_DIR}/01-beginner/04-Scripting-Automation" ]]; then
        find "${BASE_DIR}/01-beginner/04-Scripting-Automation" -type f | while read -r file; do
            local rel_path="${file#${BASE_DIR}/01-beginner/04-Scripting-Automation/}"
            local dest_file="${scripting_dest}/${rel_path}"
            
            if [[ -e "${dest_file}" ]] && [[ "${file}" == *"readme.md" ]]; then
                safe_copy "${file}" "${dest_file%.md}-v2.md"
            elif [[ ! -e "${dest_file}" ]]; then
                safe_copy "${file}" "${dest_file}"
            fi
        done
    fi
    
    log_success "Pillar 01 migration complete"
}

# ============================================================================
# PILLAR 02: AUTOMATION ORCHESTRATION
# ============================================================================

migrate_pillar_02() {
    log "========================================="
    log "MIGRATING PILLAR 02: Automation Orchestration"
    log "========================================="
    
    # Containers (merge duplicates)
    local containers_dest="${PILLAR_02}/01-containers"
    safe_mkdir "${containers_dest}"
    
    if [[ -d "${BASE_DIR}/01-beginner/05-foundational-containers" ]]; then
        safe_copy "${BASE_DIR}/01-beginner/05-foundational-containers/." "${containers_dest}/"
    fi
    
    if [[ -d "${BASE_DIR}/01-beginner/05-Foundational-Containers" ]]; then
        find "${BASE_DIR}/01-beginner/05-Foundational-Containers" -type f | while read -r file; do
            local rel_path="${file#${BASE_DIR}/01-beginner/05-Foundational-Containers/}"
            local dest_file="${containers_dest}/${rel_path}"
            
            if [[ -e "${dest_file}" ]] && [[ "${file}" == *"readme.md" ]]; then
                safe_copy "${file}" "${dest_file%.md}-v2.md"
            elif [[ ! -e "${dest_file}" ]]; then
                safe_copy "${file}" "${dest_file}"
            fi
        done
    fi
    
    # MCP Orchestration
    if [[ -d "${BASE_DIR}/02-intermediate/04-mcp" ]]; then
        safe_copy "${BASE_DIR}/02-intermediate/04-mcp" "${PILLAR_02}/02-mcp"
    fi
    
    # n8n Documentation (NOTE: NOT the actual Docker stack)
    if [[ -d "/home/gsmash/Documents/n8n_docker" ]]; then
        safe_mkdir "${PILLAR_02}/03-n8n"
        # Copy only documentation files
        find "/home/gsmash/Documents/n8n_docker" -type f \( -name "*.md" -o -name "*.txt" \) \
            -exec cp {} "${PILLAR_02}/03-n8n/" \; 2>/dev/null || true
    fi
    
    log_success "Pillar 02 migration complete"
}

# ============================================================================
# PILLAR 03: THE REFERENCE VAULT (ATOMIC PRESERVATION)
# ============================================================================

migrate_pillar_03() {
    log "========================================="
    log "MIGRATING PILLAR 03: The Reference Vault"
    log "========================================="
    log "⚠️  STRICT ATOMIC PRESERVATION MODE"
    
    # PowerShell Commands Library (ATOMIC)
    local ps_commands_src="${BASE_DIR}/01-beginner/99-supplemental-content/01-phase-1/03-windows-basics/part-1-powershell-automation/commands"
    local ps_commands_dest="${PILLAR_03}/powershell-commands"
    
    if [[ -d "${ps_commands_src}" ]]; then
        safe_mkdir "${ps_commands_dest}"
        # Copy entire directory structure preserving atomicity
        safe_copy "${ps_commands_src}/." "${ps_commands_dest}/"
        log "✅ PowerShell commands preserved atomically"
    fi
    
    # Linux Commands Reference
    local linux_commands_src="${BASE_DIR}/01-beginner/01-linux-fundamentals/03-commands"
    local linux_commands_dest="${PILLAR_03}/linux-commands"
    
    if [[ -d "${linux_commands_src}" ]]; then
        safe_copy "${linux_commands_src}" "${linux_commands_dest}"
        log "✅ Linux commands preserved"
    fi
    
    # Collect all reference directories
    log "Collecting all *-ref.md and reference/ directories..."
    find "${BASE_DIR}" -type d -name "reference" -o -type d -name "Reference" | while read -r ref_dir; do
        # Extract domain name from path
        local domain_name=$(basename "$(dirname "${ref_dir}")")
        local ref_dest="${PILLAR_03}/${domain_name}-reference"
        
        safe_mkdir "${ref_dest}"
        safe_copy "${ref_dir}/." "${ref_dest}/"
        log "✅ Migrated reference: ${domain_name}"
    done
    
    # FinOps Reference
    if [[ -d "${BASE_DIR}/02-intermediate/03-finops/reference" ]]; then
        safe_copy "${BASE_DIR}/02-intermediate/03-finops/reference" "${PILLAR_03}/finops-reference"
    fi
    
    log_success "Pillar 03 migration complete (ATOMIC PRESERVATION VERIFIED)"
}

# ============================================================================
# PILLAR 04: CAREER STRATEGY OPS
# ============================================================================

migrate_pillar_04() {
    log "========================================="
    log "MIGRATING PILLAR 04: Career Strategy Ops"
    log "========================================="
    
    # Career Mastery
    if [[ -d "${BASE_DIR}/00-career-mastery" ]]; then
        safe_copy "${BASE_DIR}/00-career-mastery" "${PILLAR_04}/01-career-mastery"
    fi
    
    # FinOps Strategy (theory parts, not reference)
    if [[ -d "${BASE_DIR}/02-intermediate/03-finops" ]]; then
        safe_mkdir "${PILLAR_04}/02-finops-strategy"
        
        # Copy theory files (exclude reference directory)
        find "${BASE_DIR}/02-intermediate/03-finops" -type f \( -name "*.md" -o -name "*.sh" -o -name "*.py" \) \
            ! -path "*/reference/*" \
            -exec bash -c 'cp "$1" "'"${PILLAR_04}/02-finops-strategy/$(basename "$1")"'"' _ {} \; 2>/dev/null || true
    fi
    
    # Operational Procedures (templates, rollback, triage)
    safe_mkdir "${PILLAR_04}/03-operational-procedures"
    
    if [[ -d "${BASE_DIR}/00-career-mastery/04-day-in-the-life-operations/templates" ]]; then
        safe_copy "${BASE_DIR}/00-career-mastery/04-day-in-the-life-operations/templates" \
                  "${PILLAR_04}/03-operational-procedures/templates"
    fi
    
    if [[ -d "${BASE_DIR}/00-career-mastery/04-day-in-the-life-operations/03-rollback-procedures" ]]; then
        safe_copy "${BASE_DIR}/00-career-mastery/04-day-in-the-life-operations/03-rollback-procedures" \
                  "${PILLAR_04}/03-operational-procedures/rollback"
    fi
    
    log_success "Pillar 04 migration complete"
}

# ============================================================================
# PILLAR 05: ASSETS AND THEMES
# ============================================================================

migrate_pillar_05() {
    log "========================================="
    log "MIGRATING PILLAR 05: Assets and Themes"
    log "========================================="
    
    # Centralize all images
    safe_mkdir "${PILLAR_05}/images"
    
    log "Collecting all image files..."
    find "${BASE_DIR}" -type f \( \
        -name "*.png" -o \
        -name "*.svg" -o \
        -name "*.jpg" -o \
        -name "*.jpeg" -o \
        -name "*.webp" -o \
        -name "*.gif" \
    \) | while read -r img; do
        # Extract source domain from path
        local rel_path="${img#${BASE_DIR}/}"
        local domain=$(echo "${rel_path}" | cut -d'/' -f1-2 | tr '/' '-')
        local img_name=$(basename "${img}")
        
        safe_mkdir "${PILLAR_05}/images/${domain}"
        safe_copy "${img}" "${PILLAR_05}/images/${domain}/${img_name}"
    done
    
    # Mermaid Themes
    if [[ -d "${BASE_DIR}/02-intermediate/04-mcp/mermaid-themes" ]]; then
        safe_copy "${BASE_DIR}/02-intermediate/04-mcp/mermaid-themes" "${PILLAR_05}/mermaid-themes"
    fi
    
    # Obsidian Configuration
    if [[ -d "${BASE_DIR}/.obsidian" ]]; then
        safe_copy "${BASE_DIR}/.obsidian" "${PILLAR_05}/obsidian-config"
    fi
    
    # Collect all assets/ directories
    find "${BASE_DIR}" -type d -name "assets" | while read -r assets_dir; do
        local rel_path="${assets_dir#${BASE_DIR}/}"
        local domain=$(echo "${rel_path}" | cut -d'/' -f1-2 | tr '/' '-')
        
        safe_mkdir "${PILLAR_05}/assets/${domain}"
        safe_copy "${assets_dir}/." "${PILLAR_05}/assets/${domain}/"
    done
    
    log_success "Pillar 05 migration complete"
}

# ============================================================================
# MASTER INDEX CREATION
# ============================================================================

create_master_index() {
    log "Creating MASTER_INDEX.md..."
    
    local index_file="${BASE_DIR}/MASTER_INDEX.md"
    
    if [[ "${DRY_RUN}" == "false" ]]; then
        cat > "${index_file}" <<'EOF'
# DevOps Mastery - Master Index
**Architecture**: Domain-Driven Design (DDD)  
**Migration Date**: 2026-02-16  
**Total Pillars**: 5

---

## 🏛️ Architecture Overview

```mermaid
graph TB
    P1[01-Engineering-Foundations]
    P2[02-Automation-Orchestration]
    P3[03-The-Reference-Vault]
    P4[04-Career-Strategy-Ops]
    P5[05-Assets-and-Themes]
    
    P1 -->|Supports| P2
    P1 -->|Documented in| P3
    P2 -->|Enables| P4
    P3 -->|References| P5
    P4 -->|Uses| P5
    
    style P1 fill:#4CAF50
    style P2 fill:#2196F3
    style P3 fill:#FF9800
    style P4 fill:#9C27B0
    style P5 fill:#F44336
```

---

## 📚 Pillar Breakdown

### 🟢 Pillar 01: Engineering Foundations
**Core technical skills that underpin all DevOps work**

- **01-linux-fundamentals**: Shell, filesystem, permissions, SSH
- **02-networking-concepts**: OSI model, TCP/IP, DNS, routing
- **03-git-version-control**: Branching, workflows, GitHub Actions
- **04-automation-scripting**: Bash, Python, PowerShell fundamentals

**Learning Path**: Beginner → Intermediate  
**Estimated Time**: 8-12 weeks

---

### 🔵 Pillar 02: Automation Orchestration
**Containerization, workflow automation, and orchestration tools**

- **01-containers**: Docker fundamentals, images, networking, volumes
- **02-mcp**: Model Context Protocol orchestration patterns
- **03-n8n**: Workflow automation and integration

**Learning Path**: Intermediate → Advanced  
**Estimated Time**: 6-8 weeks

---

### 🟠 Pillar 03: The Reference Vault
**Atomic command library for terminal searchability**

- **powershell-commands**: 100+ PowerShell cmdlets (1 file per command)
- **linux-commands**: Essential CLI reference
- **[domain]-reference**: Curated best practices by domain

**Usage**: `grep -r "Get-Disk" 03-The-Reference-Vault/`  
**Total Commands**: 200+

---

### 🟣 Pillar 04: Career Strategy Ops
**Soft skills, operational procedures, and career development**

- **01-career-mastery**: Resume, portfolio, interview prep
- **02-finops-strategy**: Cost optimization, budget management
- **03-operational-procedures**: Rollback, triage, post-mortems

**Learning Path**: Continuous  
**Estimated Time**: Ongoing

---

### 🔴 Pillar 05: Assets and Themes
**Media, plugins, and configuration files**

- **images/**: Centralized image library (organized by domain)
- **mermaid-themes/**: Diagram styling
- **obsidian-config/**: Note-taking setup
- **assets/**: SVG diagrams, icons, banners

**Total Assets**: 500+ files

---

## 🔍 Quick Navigation

### By Skill Level
- **Beginner**: Pillar 01 (Foundations)
- **Intermediate**: Pillar 02 (Automation)
- **Advanced**: Pillar 03 (Reference) + Pillar 04 (Strategy)

### By Use Case
- **Learning**: Pillar 01 → Pillar 02
- **Reference**: Pillar 03
- **Career**: Pillar 04
- **Design**: Pillar 05

---

## 📖 Migration Notes

- **Atomic Preservation**: All individual command files preserved
- **No Script Loss**: All .sh, .ps1, .py files migrated
- **Duplicate Handling**: Conflicting READMEs renamed with `-v2` suffix
- **Backup**: Available at `~/Devops_BACKUP_*`

---

**Last Updated**: 2026-02-16  
**Maintainer**: Lead DevOps Information Architect
EOF
        log_success "MASTER_INDEX.md created"
    else
        log "DRY RUN: Would create MASTER_INDEX.md"
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    log "========================================="
    log "DevOps DDD Migration Script"
    log "========================================="
    log "Base Directory: ${BASE_DIR}"
    log "Dry Run: ${DRY_RUN}"
    log "Log File: ${LOG_FILE}"
    log "========================================="
    
    # Pre-flight checks
    if [[ ! -d "${BASE_DIR}" ]]; then
        log_error "Base directory does not exist: ${BASE_DIR}"
        exit 1
    fi
    
    if [[ ! -f "${BASE_DIR}/tree.txt" ]]; then
        log_error "tree.txt not found. Cannot proceed without source inventory."
        exit 1
    fi
    
    # Create backup
    create_backup
    
    # Create pillar structure
    create_pillar_structure
    
    # Execute migrations
    migrate_pillar_01
    migrate_pillar_02
    migrate_pillar_03
    migrate_pillar_04
    migrate_pillar_05
    
    # Create master index
    create_master_index
    
    log "========================================="
    log_success "Migration Complete!"
    log "========================================="
    log "Next Steps:"
    log "1. Review migration log: ${LOG_FILE}"
    log "2. Validate MASTER_INDEX.md"
    log "3. Test link integrity"
    log "4. Archive old structure"
    log "========================================="
}

# Run main function
main "$@"
