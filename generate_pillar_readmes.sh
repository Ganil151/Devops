#!/usr/bin/env bash
# Generate Pillar Master READMEs

BASE_DIR="/home/gsmash/Documents/Devops"

# Pillar 1
cat > "${BASE_DIR}/01-Engineering-Foundations/MASTER_README.md" <<EOF
# Pillar 01: Engineering Foundations
This pillar contains the core technical skills that underpin all DevOps work.

## Sub-Directories
- **01-linux-fundamentals**: GNU/Linux engineering, shell, and security.
- **02-networking-concepts**: OSI models and network protocols.
- **03-git-version-control**: Distributed version control and collaboration workflows.
- **04-automation-scripting**: Scripting foundations in Bash, Python, and PowerShell.

[Back to Master Index](../MASTER_INDEX.md)
EOF

# Pillar 2
cat > "${BASE_DIR}/02-Automation-Orchestration/MASTER_README.md" <<EOF
# Pillar 02: Automation & Orchestration
This pillar focuses on containerization, software lifecycle automation, and orchestration platforms.

## Sub-Directories
- **01-containers**: Docker foundations and container runtime management.
- **02-mcp**: Model Context Protocol (MCP) implementations.
- **03-n8n**: Workflow automation and low-code orchestration.

[Back to Master Index](../MASTER_INDEX.md)
EOF

# Pillar 3
cat > "${BASE_DIR}/03-The-Reference-Vault/MASTER_README.md" <<EOF
# Pillar 03: The Reference Vault
STRICT ATOMIC PRESERVATION. This is a library of CLI commands and reference documentation for searchability.

## Sub-Directories
- **powershell-commands**: Atomic PowerShell library (1 file per cmdlet).
- **linux-commands**: CLI command lists.
- **[domain]-reference**: Technical reference files across all domains.

[Back to Master Index](../MASTER_INDEX.md)
EOF

# Pillar 4
cat > "${BASE_DIR}/04-Career-Strategy-Ops/MASTER_README.md" <<EOF
# Pillar 04: Career Strategy & Ops
Combining soft skills with operational procedures like Rollbacks and Triage.

## Sub-Directories
- **01-career-mastery**: DevOps persona, tool landscape, and interview mastery.
- **02-finops-strategy**: Cloud financial operations and theoretical strategy.
- **03-operational-procedures**: Post-mortem templates and triage procedures.

[Back to Master Index](../MASTER_INDEX.md)
EOF
# Wait, Pillar 4 target was written to a file instead of a directory. I'll fix it below.

# Pillar 5
cat > "${BASE_DIR}/05-Assets-and-Themes/MASTER_README.md" <<EOF
# Pillar 05: Assets & Themes
Centralized media, plugins, and configuration files to ensure global link integrity.

## Sub-Directories
- **images/**: Centralized image assets.
- **mermaid-themes/**: Custom Mermaid diagram styling.
- **obsidian-config/**: Vault settings and plugins.
- **assets/**: SVG icons and banners.

[Back to Master Index](../MASTER_INDEX.md)
EOF
