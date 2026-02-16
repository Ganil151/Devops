# Global Structural Refactor - Migration Plan
**Standard**: Domain-Driven Design (DDD)  
**Date**: 2026-02-16  
**Architect**: Lead DevOps Information Architect

---

## Executive Summary
This migration restructures the entire `/home/gsmash/Documents/Devops` directory from a phase-based organization (Beginner/Intermediate/Advanced) into **5 high-level Domain Pillars** that follow DDD principles while maintaining atomic preservation of all technical command files.

---

## 🎯 Core Principles

### 1. **Atomic Preservation**
- **NO consolidation** of individual command files (e.g., `get-disk.md`, `get-volume.md`)
- Each CLI command remains a separate, searchable file
- Scripts (.sh, .ps1, .py) are NEVER deleted

### 2. **Path Accuracy**
- All operations use absolute paths: `/home/gsmash/Documents/Devops/...`
- Source data: `tree.txt` (13,628 lines, 974KB)

### 3. **No Hallucination**
- Only files found in `tree.txt` are migrated
- No invented content or merged files

---

## 📐 Target Architecture: 5 Pillars

### **Pillar 01: Engineering-Foundations**
**Purpose**: Core technical skills that underpin all DevOps work

**Source Content**:
```
/01-beginner/01-Linux-Engineering/          → /01-Engineering-Foundations/01-linux-fundamentals/
/01-beginner/01-linux-fundamentals/         → /01-Engineering-Foundations/01-linux-fundamentals/
/01-beginner/02-Network-Protocols/          → /01-Engineering-Foundations/02-networking-concepts/
/01-beginner/02-networking-concepts/        → /01-Engineering-Foundations/02-networking-concepts/
/01-beginner/03-Git-Version-Control/        → /01-Engineering-Foundations/03-git-version-control/
/01-beginner/03-git-version-control/        → /01-Engineering-Foundations/03-git-version-control/
/01-beginner/04-automation-scripting/       → /01-Engineering-Foundations/04-automation-scripting/
/01-beginner/04-Scripting-Automation/       → /01-Engineering-Foundations/04-automation-scripting/
```

**Merge Logic**:
- Combine duplicate directories (e.g., `01-Linux-Engineering` + `01-linux-fundamentals`)
- Keep most comprehensive README, append `-v2` to others
- Preserve all Fedora scripts from `05-distros/01-rhel-family/fedora/scripts/`

---

### **Pillar 02: Automation-Orchestration**
**Purpose**: Containerization, workflow automation, and orchestration tools

**Source Content**:
```
/01-beginner/05-foundational-containers/    → /02-Automation-Orchestration/01-containers/
/01-beginner/05-Foundational-Containers/    → /02-Automation-Orchestration/01-containers/
/02-intermediate/04-mcp/                    → /02-Automation-Orchestration/02-mcp/
/home/gsmash/Documents/n8n_docker/ (docs)   → /02-Automation-Orchestration/03-n8n/
```

**Merge Logic**:
- Combine Docker fundamentals from both `05-foundational-containers` variants
- Extract n8n documentation (NOT the actual Docker stack)
- Group MCP orchestration patterns

---

### **Pillar 03: The-Reference-Vault**
**Purpose**: Atomic command library for terminal searchability

**Source Content**:
```
/01-beginner/99-supplemental-content/01-phase-1/03-windows-basics/part-1-powershell-automation/commands/
  → /03-The-Reference-Vault/powershell-commands/

/01-beginner/01-linux-fundamentals/03-commands/
  → /03-The-Reference-Vault/linux-commands/

/02-intermediate/03-finops/reference/
  → /03-The-Reference-Vault/finops-reference/

All */reference/ directories
  → /03-The-Reference-Vault/[domain]-reference/
```

**Critical Rules**:
- **STRICT ATOMIC PRESERVATION**: 1 file per command
- Maintain directory structure: `diskandstorage/get-disk.md`, `network/get-netadapter.md`
- Keep all `*-ref.md` files separate

---

### **Pillar 04: Career-Strategy-Ops**
**Purpose**: Soft skills, operational procedures, and career development

**Source Content**:
```
/00-career-mastery/                         → /04-Career-Strategy-Ops/01-career-mastery/
/02-intermediate/03-finops/ (theory)        → /04-Career-Strategy-Ops/02-finops-strategy/
/00-career-mastery/04-day-in-the-life-operations/templates/
  → /04-Career-Strategy-Ops/03-operational-procedures/templates/
```

**Merge Logic**:
- Separate FinOps theory from technical reference
- Group post-mortem templates, rollback procedures, triage workflows
- Preserve interview prep and resume engineering

---

### **Pillar 05: Assets-and-Themes**
**Purpose**: Media, plugins, and configuration files

**Source Content**:
```
All *.png, *.svg, *.jpg, *.webp files       → /05-Assets-and-Themes/images/
/02-intermediate/04-mcp/mermaid-themes/     → /05-Assets-and-Themes/mermaid-themes/
/.obsidian/                                 → /05-Assets-and-Themes/obsidian-config/
All assets/ directories                     → /05-Assets-and-Themes/[source-domain]/
```

**Merge Logic**:
- Centralize all media to fix broken Markdown links
- Group by source domain (e.g., `networking-assets/`, `python-assets/`)
- Preserve Obsidian plugin configurations

---

## 🔧 Migration Workflow

### Phase 1: Pre-Migration Audit
1. ✅ Parse `tree.txt` to create file inventory
2. ✅ Identify duplicates (e.g., `01-Linux-Engineering` vs `01-linux-fundamentals`)
3. ✅ Map all `readme.md` files for consolidation analysis
4. ✅ Catalog all scripts (.sh, .ps1, .py) for preservation

### Phase 2: Pillar Creation
1. Create 5 pillar directories with MASTER_README.md
2. Generate Mermaid diagrams showing pillar relationships
3. Create index files for each subdomain

### Phase 3: Atomic Migration
1. **Pillar 01**: Migrate Linux, Networking, Git, Scripting
2. **Pillar 02**: Migrate Containers, MCP, n8n docs
3. **Pillar 03**: Migrate all command libraries (ATOMIC)
4. **Pillar 04**: Migrate career content and operational procedures
5. **Pillar 05**: Centralize all media and themes

### Phase 4: Link Repair
1. Update all Markdown links to new paths
2. Fix image references in README files
3. Validate all internal links

### Phase 5: Cleanup
1. Identify redundant README files
2. Append `-v2` to less comprehensive versions
3. Create deprecation notices in old directories

---

## 📊 Success Metrics

- ✅ **Zero file loss**: All files from `tree.txt` accounted for
- ✅ **Atomic preservation**: All individual command files remain separate
- ✅ **No script deletion**: All .sh, .ps1, .py files preserved
- ✅ **Searchability**: Terminal `grep` works across command library
- ✅ **Link integrity**: No broken Markdown links

---

## 🚨 Risk Mitigation

### Backup Strategy
```bash
# Create timestamped backup before migration
tar -czf ~/Devops_BACKUP_$(date +%Y%m%d_%H%M%S).tar.gz /home/gsmash/Documents/Devops/
```

### Rollback Plan
- Keep `01-beginner_RECOVERY/` directory intact
- Maintain `tree.txt` as golden reference
- Use `git` to track all changes

---

## 📝 Next Steps

1. **Review this plan** for accuracy
2. **Execute migration script** (to be generated)
3. **Create MASTER_INDEX.md** with Mermaid diagrams
4. **Validate** all links and references
5. **Archive** old structure with deprecation notices

---

**Approval Required**: YES  
**Estimated Duration**: 2-4 hours  
**Reversibility**: HIGH (via backup + git)
