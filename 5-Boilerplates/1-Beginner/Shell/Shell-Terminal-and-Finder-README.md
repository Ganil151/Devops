# Boilerplates: Terminal and Finder
This directory contains boilerplate scripts demonstrating navigation and file discovery automation for DevOps workflows.
## Available Boilerplates

### 1. Repository Structure Analyzer
**File**: `boilerplate_repo_structure_analyzer.sh`
**Purpose**: Generates auto-documented repository structure
**DevOps Use Case**: Onboarding new engineers with clear directory maps

**Usage**:
```bash
./boilerplate_repo_structure_analyzer.sh [target_directory]
```

**Output**: Creates `REPOSITORY_STRUCTURE.md` with formatted tree view

**Features**:
- Automatic tree generation
- Excludes common ignored directories (.git, node_modules, .terraform)
- Markdown-formatted output
- Configurable depth levels

---
### 2. Log Archiver
**File**: `boilerplate_log_archiver.sh`
**Purpose**: Compresses and archives old log files for compliance
**DevOps Use Case**: Automated log retention for regulatory requirements

**Usage**:
```bash
./boilerplate_log_archiver.sh [log_dir] [archive_dir]
```
**Default Behavior**:
- Searches `/var/log` for logs older than 30 days
- Creates compressed archives in `/var/log/archives`
- Removes archives older than 90 days

**Cron Schedule** (weekly on Sunday at 3 AM):
```bash
0 3 * * 0 /path/to/boilerplate_log_archiver.sh
```

**Features**:
- Time-based log filtering
- Compressed tar.gz archives
- Automatic cleanup of old archives
- Safe deletion after archive creation
- Archive size reporting

---
## Quick Start

1. Make scripts executable:
```bash
chmod +x boilerplate_*.sh
```

2. Run repository analyzer:
```bash
./boilerplate_repo_structure_analyzer.sh .
```

3. Run log archiver:
```bash
./boilerplate_log_archiver.sh /var/log /backup/logs
```

---

## Learning Objectives

These boilerplates demonstrate:
- ✅ `find` command mastery for file discovery
- ✅ Directory tree visualization
- ✅ Time-based file filtering (`-mtime`)
- ✅ Archive creation with `tar`
- ✅ Safe file deletion workflows
- ✅ Scheduled automation patterns

---

## Related Resources

- [Parent Module: Terminal and Finder](../../../README.md)
- [Challenges](../../../1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/01-Introduction/CHALLENGES.md)
