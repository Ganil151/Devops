#!/bin/bash
# =============================================================================
# DevOps Study Guide Reorganization Script
# =============================================================================
# This script reorganizes the DevOps study guide into a tiered, logical 
# learning path with kebab-case naming conventions.
# =============================================================================

set -e  # Exit on error

ROOT_DIR="/home/ganil/Documents/Devops"
cd "$ROOT_DIR"

echo "=== DevOps Study Guide Reorganization ==="
echo "Root directory: $ROOT_DIR"
echo ""

# =============================================================================
# PHASE 1: Create New Directory Structure
# =============================================================================
echo "PHASE 1: Creating new directory structure..."

# Foundation Tier
mkdir -p 01-foundation/01-linux-administration/{distros,permissions,scripts/{bash,python,zsh}}
mkdir -p 01-foundation/02-networking-architecture/{osi-model,ip-addressing,protocols,troubleshooting,scripts}
mkdir -p 01-foundation/03-version-control-git/{fundamentals,workflows,github-actions}
mkdir -p 01-foundation/04-windows-automation/{powershell,wsl,performance-tuning,scripts}

# Core Engineering Tier
mkdir -p 02-core-engineering/01-cloud-aws/{compute,networking,serverless,containers,security}
mkdir -p 02-core-engineering/02-infrastructure-as-code/{terraform,terragrunt,ansible,packer}
mkdir -p 02-core-engineering/03-automation-python/{foundations,systems,boto3,testing}
mkdir -p 02-core-engineering/04-containers-orchestration/{docker,kubernetes,helm,service-mesh}

# Career Strategy Tier
mkdir -p 03-career-strategy/01-personal-branding/{github,linkedin,portfolio}
mkdir -p 03-career-strategy/02-resume-engineering/{templates,examples,resources}
mkdir -p 03-career-strategy/03-soft-skills/{communication,day-in-life,prioritization}

# Interview Readiness Tier
mkdir -p 04-interview-readiness/01-technical-knowledge-base/{flashcards,deep-dives}
mkdir -p 04-interview-readiness/02-behavioral-star-method/{scenarios,templates}
mkdir -p 04-interview-readiness/03-live-coding-assessment/{challenges,solutions}
mkdir -p 04-interview-readiness/04-negotiation-hiring/{salary,hiring-process}

# Assets Tier
mkdir -p assets/{images,scripts/{bash,python,powershell},templates}

echo "✓ Directory structure created"
echo ""

# =============================================================================
# PHASE 2: Migrate Linux Administration Content
# =============================================================================
echo "PHASE 2: Migrating Linux Administration content..."

# Copy Linux fundamentals from 01-beginner/01-linux-fundamentals
if [ -d "01-beginner/01-linux-fundamentals" ]; then
    cp -r 01-beginner/01-linux-fundamentals/* 01-foundation/01-linux-administration/ 2>/dev/null || true
    
    # Reorganize distros
    if [ -d "01-beginner/01-linux-fundamentals/05-distros" ]; then
        cp -r 01-beginner/01-linux-fundamentals/05-distros/* 01-foundation/01-linux-administration/distros/ 2>/dev/null || true
    fi
    
    # Move scripts to centralized location
    if [ -d "01-beginner/01-linux-fundamentals/scripts/bash" ]; then
        cp 01-beginner/01-linux-fundamentals/scripts/bash/*.sh 01-foundation/01-linux-administration/scripts/bash/ 2>/dev/null || true
        cp 01-beginner/01-linux-fundamentals/scripts/bash/*.sh assets/scripts/bash/ 2>/dev/null || true
    fi
    if [ -d "01-beginner/01-linux-fundamentals/scripts/python" ]; then
        cp 01-beginner/01-linux-fundamentals/scripts/python/*.py 01-foundation/01-linux-administration/scripts/python/ 2>/dev/null || true
        cp 01-beginner/01-linux-fundamentals/scripts/python/*.py assets/scripts/python/ 2>/dev/null || true
    fi
fi

# Copy Fedora scripts from nested location
if [ -d "01-beginner/01-linux-fundamentals/05-distros/01-rhel-family/fedora/scripts" ]; then
    cp -r 01-beginner/01-linux-fundamentals/05-distros/01-rhel-family/fedora/scripts/* 01-foundation/01-linux-administration/scripts/ 2>/dev/null || true
fi

echo "✓ Linux Administration content migrated"
echo ""

# =============================================================================
# PHASE 3: Migrate Networking Content
# =============================================================================
echo "PHASE 3: Migrating Networking Architecture content..."

if [ -d "01-beginner/02-networking-concepts" ]; then
    # Copy main networking content
    cp -r 01-beginner/02-networking-concepts/* 01-foundation/02-networking-architecture/ 2>/dev/null || true
    
    # Copy OSI model content
    if [ -d "01-beginner/02-networking-concepts/02-network-models/osi-model" ]; then
        cp -r 01-beginner/02-networking-concepts/02-network-models/osi-model/* 01-foundation/02-networking-architecture/osi-model/ 2>/dev/null || true
    fi
    
    # Copy scripts
    if [ -d "01-beginner/02-networking-concepts/scripts" ]; then
        cp 01-beginner/02-networking-concepts/scripts/*.ps1 01-foundation/02-networking-architecture/scripts/ 2>/dev/null || true
        cp 01-beginner/02-networking-concepts/scripts/*.ps1 assets/scripts/powershell/ 2>/dev/null || true
    fi
fi

# Copy advanced networking from intermediate
if [ -d "02-intermediate/01-phase-1/01-networking" ]; then
    cp -r 02-intermediate/01-phase-1/01-networking/* 01-foundation/02-networking-architecture/advanced/ 2>/dev/null || true
fi

echo "✓ Networking Architecture content migrated"
echo ""

# =============================================================================
# PHASE 4: Migrate Git Content
# =============================================================================
echo "PHASE 4: Migrating Git Version Control content..."

if [ -d "01-beginner/03-git-version-control" ]; then
    cp -r 01-beginner/03-git-version-control/* 01-foundation/03-version-control-git/ 2>/dev/null || true
    
    # Organize by level
    if [ -d "01-beginner/03-git-version-control/01-beginner-level" ]; then
        cp -r 01-beginner/03-git-version-control/01-beginner-level/* 01-foundation/03-version-control-git/fundamentals/ 2>/dev/null || true
    fi
    if [ -d "01-beginner/03-git-version-control/02-intermediate-level" ]; then
        cp -r 01-beginner/03-git-version-control/02-intermediate-level/* 01-foundation/03-version-control-git/workflows/ 2>/dev/null || true
    fi
    if [ -d "01-beginner/03-git-version-control/03-advanced-level" ]; then
        cp -r 01-beginner/03-git-version-control/03-advanced-level/* 01-foundation/03-version-control-git/advanced/ 2>/dev/null || true
    fi
fi

echo "✓ Git Version Control content migrated"
echo ""

# =============================================================================
# PHASE 5: Migrate Windows Automation Content
# =============================================================================
echo "PHASE 5: Migrating Windows Automation content..."

if [ -d "01-beginner/03-windows-basics" ]; then
    # PowerShell automation
    if [ -d "01-beginner/03-windows-basics/part-1-powershell-automation" ]; then
        cp -r 01-beginner/03-windows-basics/part-1-powershell-automation/* 01-foundation/04-windows-automation/powershell/ 2>/dev/null || true
        
        # Copy PowerShell scripts
        if [ -d "01-beginner/03-windows-basics/part-1-powershell-automation/scripts" ]; then
            cp 01-beginner/03-windows-basics/part-1-powershell-automation/scripts/*.ps1 01-foundation/04-windows-automation/scripts/ 2>/dev/null || true
            cp 01-beginner/03-windows-basics/part-1-powershell-automation/scripts/*.ps1 assets/scripts/powershell/ 2>/dev/null || true
        fi
    fi
    
    # WSL integration
    if [ -d "01-beginner/03-windows-basics/part-2-wsl-linux-integration" ]; then
        cp -r 01-beginner/03-windows-basics/part-2-wsl-linux-integration/* 01-foundation/04-windows-automation/wsl/ 2>/dev/null || true
    fi
    
    # Performance tuning
    if [ -d "01-beginner/03-windows-basics/part-7-performance-tuning" ]; then
        cp -r 01-beginner/03-windows-basics/part-7-performance-tuning/* 01-foundation/04-windows-automation/performance-tuning/ 2>/dev/null || true
    fi
fi

echo "✓ Windows Automation content migrated"
echo ""

# =============================================================================
# PHASE 6: Migrate AWS Cloud Content
# =============================================================================
echo "PHASE 6: Migrating AWS Cloud content..."

# Collect AWS content from multiple sources
AWS_CONTENT_FOUND=0

# From beginner supplemental
if [ -d "01-beginner/99-supplemental-content/01-phase-1/07-cloud-foundations/05-aws-basics" ]; then
    cp -r 01-beginner/99-supplemental-content/01-phase-1/07-cloud-foundations/05-aws-basics/* 02-core-engineering/01-cloud-aws/ 2>/dev/null || true
    AWS_CONTENT_FOUND=1
fi

# From intermediate cloud platforms
if [ -d "02-intermediate/02-phase-2/01-infrastructure-automation/03-cloud-platforms" ]; then
    cp -r 02-intermediate/02-phase-2/01-infrastructure-automation/03-cloud-platforms/* 02-core-engineering/01-cloud-aws/ 2>/dev/null || true
    AWS_CONTENT_FOUND=1
fi

# From advanced networking
if [ -d "03-advanced/01-phase-1/01-networking" ]; then
    cp -r 03-advanced/01-phase-1/01-networking/* 02-core-engineering/01-cloud-aws/networking/ 2>/dev/null || true
    AWS_CONTENT_FOUND=1
fi

# Copy AWS interview deep dive
if [ -f "00-career-mastery/09-interview-mastery/01-technical-deep-dives/aws-s3.md" ]; then
    cp 00-career-mastery/09-interview-mastery/01-technical-deep-dives/aws-s3.md 02-core-engineering/01-cloud-aws/storage/ 2>/dev/null || true
fi

# Copy AWS scripts
find . -name "*aws*.sh" -o -name "*aws*.py" -o -name "*aws*.ps1" 2>/dev/null | head -20 | while read file; do
    if [[ "$file" == *.sh ]]; then
        cp "$file" assets/scripts/bash/ 2>/dev/null || true
    elif [[ "$file" == *.py ]]; then
        cp "$file" assets/scripts/python/ 2>/dev/null || true
    elif [[ "$file" == *.ps1 ]]; then
        cp "$file" assets/scripts/powershell/ 2>/dev/null || true
    fi
done

echo "✓ AWS Cloud content migrated"
echo ""

# =============================================================================
# PHASE 7: Migrate Infrastructure as Code Content
# =============================================================================
echo "PHASE 7: Migrating Infrastructure as Code content..."

# Terraform from advanced automation
if [ -d "03-advanced/01-phase-1/02-automation/terraform" ]; then
    cp -r 03-advanced/01-phase-1/02-automation/terraform/* 02-core-engineering/02-infrastructure-as-code/terraform/ 2>/dev/null || true
fi

# Terraform from intermediate
if [ -d "02-intermediate/02-phase-2/01-infrastructure-automation/02-config-management/02-iac-foundations-and-terraform" ]; then
    cp -r 02-intermediate/02-phase-2/01-infrastructure-automation/02-config-management/02-iac-foundations-and-terraform/* 02-core-engineering/02-infrastructure-as-code/terraform/fundamentals/ 2>/dev/null || true
fi

# Boilerplates
if [ -d "07-boilerplates/02-intermediate/terraform" ]; then
    cp -r 07-boilerplates/02-intermediate/terraform/* 02-core-engineering/02-infrastructure-as-code/terraform/boilerplates/ 2>/dev/null || true
fi

# Ansible
if [ -d "03-advanced/01-phase-1/02-automation/ansible" ]; then
    cp -r 03-advanced/01-phase-1/02-automation/ansible/* 02-core-engineering/02-infrastructure-as-code/ansible/ 2>/dev/null || true
fi

# Copy Terraform interview deep dive
if [ -f "00-career-mastery/09-interview-mastery/01-technical-deep-dives/terraform.md" ]; then
    cp 00-career-mastery/09-interview-mastery/01-technical-deep-dives/terraform.md 02-core-engineering/02-infrastructure-as-code/ 2>/dev/null || true
fi

echo "✓ Infrastructure as Code content migrated"
echo ""

# =============================================================================
# PHASE 8: Migrate Python Automation Content
# =============================================================================
echo "PHASE 8: Migrating Python Automation content..."

if [ -d "01-beginner/04-automation-scripting/03-python-basics" ]; then
    # Copy Python foundations
    if [ -d "01-beginner/04-automation-scripting/03-python-basics/01-python-foundations" ]; then
        cp -r 01-beginner/04-automation-scripting/03-python-basics/01-python-foundations/* 02-core-engineering/03-automation-python/foundations/ 2>/dev/null || true
    fi
    
    # Copy Python architecture
    if [ -d "01-beginner/04-automation-scripting/03-python-basics/02-python-architecture" ]; then
        cp -r 01-beginner/04-automation-scripting/03-python-basics/02-python-architecture/* 02-core-engineering/03-automation-python/ 2>/dev/null || true
    fi
    
    # Copy systems drafting
    if [ -d "01-beginner/04-automation-scripting/03-python-basics/03-python-systems-drafting" ]; then
        cp -r 01-beginner/04-automation-scripting/03-python-basics/03-python-systems-drafting/* 02-core-engineering/03-automation-python/systems/ 2>/dev/null || true
    fi
fi

# Copy Python scripts to assets
find 01-beginner/04-automation-scripting -name "*.py" 2>/dev/null | head -30 | while read file; do
    cp "$file" assets/scripts/python/ 2>/dev/null || true
done

echo "✓ Python Automation content migrated"
echo ""

# =============================================================================
# PHASE 9: Migrate Containers & Orchestration Content
# =============================================================================
echo "PHASE 9: Migrating Containers & Orchestration content..."

# Docker and Kubernetes from intermediate containers
if [ -d "02-intermediate/05-foundational-containers" ]; then
    cp -r 02-intermediate/05-foundational-containers/* 02-core-engineering/04-containers-orchestration/ 2>/dev/null || true
fi

# Advanced K8s from advanced
if [ -d "03-advanced/01-phase-1/04-container-orchestration" ]; then
    cp -r 03-advanced/01-phase-1/04-container-orchestration/* 02-core-engineering/04-containers-orchestration/kubernetes/ 2>/dev/null || true
fi

# Container orchestration from phase-3
if [ -d "03-advanced/03-phase-3/02-container-orchestration" ]; then
    cp -r 03-advanced/03-phase-3/02-container-orchestration/* 02-core-engineering/04-containers-orchestration/kubernetes/advanced/ 2>/dev/null || true
fi

# Copy Docker and Kubernetes interview deep dives
if [ -f "00-career-mastery/09-interview-mastery/01-technical-deep-dives/docker.md" ]; then
    cp 00-career-mastery/09-interview-mastery/01-technical-deep-dives/docker.md 02-core-engineering/04-containers-orchestration/ 2>/dev/null || true
fi
if [ -f "00-career-mastery/09-interview-mastery/01-technical-deep-dives/kubernetes.md" ]; then
    cp 00-career-mastery/09-interview-mastery/01-technical-deep-dives/kubernetes.md 02-core-engineering/04-containers-orchestration/ 2>/dev/null || true
fi

echo "✓ Containers & Orchestration content migrated"
echo ""

# =============================================================================
# PHASE 10: Migrate Career Strategy Content
# =============================================================================
echo "PHASE 10: Migrating Career Strategy content..."

# Personal Branding from portfolio guide
if [ -d "00-career-mastery/06-portfolio-guide" ]; then
    cp -r 00-career-mastery/06-portfolio-guide/* 03-career-strategy/01-personal-branding/portfolio/ 2>/dev/null || true
fi

# Resume Engineering - deduplicate
if [ -d "00-career-mastery/07-resume-engineering" ]; then
    cp -r 00-career-mastery/07-resume-engineering/* 03-career-strategy/02-resume-engineering/ 2>/dev/null || true
    
    # Consolidate resume PDFs - keep only the most professional versions
    if [ -d "00-career-mastery/07-resume-engineering/resources/devops-resume-ganil-batistpdf" ]; then
        # Copy the main professional resume
        cp "00-career-mastery/07-resume-engineering/resources/devops-resume-ganil-batistpdf/devops-resume-ganil-batist.pdf" 03-career-strategy/02-resume-engineering/resources/ 2>/dev/null || true
        cp "00-career-mastery/07-resume-engineering/resources/devops-resume-ganil-batistpdf/devops-resume.pdf" 03-career-strategy/02-resume-engineering/resources/ 2>/dev/null || true
    fi
fi

# Soft Skills
if [ -d "00-career-mastery/03-soft-skills" ]; then
    cp -r 00-career-mastery/03-soft-skills/* 03-career-strategy/03-soft-skills/communication/ 2>/dev/null || true
fi

if [ -d "00-career-mastery/04-day-in-the-life-operations" ]; then
    cp -r 00-career-mastery/04-day-in-the-life-operations/* 03-career-strategy/03-soft-skills/day-in-life/ 2>/dev/null || true
    
    # Copy templates
    if [ -d "00-career-mastery/04-day-in-the-life-operations/templates" ]; then
        cp 00-career-mastery/04-day-in-the-life-operations/templates/*.md assets/templates/ 2>/dev/null || true
    fi
fi

# DevOps Persona and Tool Landscape
if [ -d "00-career-mastery/01-devops-persona" ]; then
    cp -r 00-career-mastery/01-devops-persona/* 03-career-strategy/01-personal-branding/ 2>/dev/null || true
fi

if [ -d "00-career-mastery/02-the-tool-landscape" ]; then
    cp -r 00-career-mastery/02-the-tool-landscape/* 03-career-strategy/01-personal-branding/ 2>/dev/null || true
fi

echo "✓ Career Strategy content migrated"
echo ""

# =============================================================================
# PHASE 11: Migrate Interview Readiness Content
# =============================================================================
echo "PHASE 11: Migrating Interview Readiness content..."

# Technical Deep Dives
if [ -d "00-career-mastery/09-interview-mastery/01-technical-deep-dives" ]; then
    # Copy remaining deep dives (AWS, Terraform, Docker, K8s already moved)
    cp 00-career-mastery/09-interview-mastery/01-technical-deep-dives/*.md 04-interview-readiness/01-technical-knowledge-base/deep-dives/ 2>/dev/null || true
fi

# Behavioral STAR Method
if [ -d "00-career-mastery/09-interview-mastery/03-behavioral-star-method" ]; then
    cp -r 00-career-mastery/09-interview-mastery/03-behavioral-star-method/* 04-interview-readiness/02-behavioral-star-method/ 2>/dev/null || true
fi

if [ -d "00-career-mastery/09-interview-mastery/02-scenario-architecture" ]; then
    cp -r 00-career-mastery/09-interview-mastery/02-scenario-architecture/* 04-interview-readiness/02-behavioral-star-method/scenarios/ 2>/dev/null || true
fi

# Live Coding Challenges
if [ -d "00-career-mastery/09-interview-mastery/04-live-coding-challenges" ]; then
    cp -r 00-career-mastery/09-interview-mastery/04-live-coding-challenges/* 04-interview-readiness/03-live-coding-assessment/ 2>/dev/null || true
fi

# Assessment Tests
if [ -d "00-career-mastery/09-interview-mastery/05-assessment-tests" ]; then
    cp -r 00-career-mastery/09-interview-mastery/05-assessment-tests/* 04-interview-readiness/03-live-coding-assessment/ 2>/dev/null || true
fi

# Interview Questions and Flashcards
if [ -d "00-career-mastery/14-Interview-Questions" ]; then
    cp 00-career-mastery/14-Interview-Questions/flashcards.csv 04-interview-readiness/01-technical-knowledge-base/flashcards/ 2>/dev/null || true
    cp 00-career-mastery/14-Interview-Questions/*.md 04-interview-readiness/01-technical-knowledge-base/deep-dives/ 2>/dev/null || true
fi

# Salary Negotiation
if [ -d "00-career-mastery/10-salary-negotiation" ]; then
    cp -r 00-career-mastery/10-salary-negotiation/* 04-interview-readiness/04-negotiation-hiring/salary/ 2>/dev/null || true
fi

# Hiring Logic
if [ -d "00-career-mastery/12-hiring-logic" ]; then
    cp -r 00-career-mastery/12-hiring-logic/* 04-interview-readiness/04-negotiation-hiring/hiring-process/ 2>/dev/null || true
fi

# Mock Interview Scripts
if [ -d "00-career-mastery/11-mock-interview-scripts" ]; then
    cp -r 00-career-mastery/11-mock-interview-scripts/* 04-interview-readiness/02-behavioral-star-method/ 2>/dev/null || true
fi

# Prompt Engineer content (ATS, LinkedIn, etc.)
if [ -d "00-career-mastery/08-prompt-engineer" ]; then
    cp 00-career-mastery/08-prompt-engineer/ats-stress-test.md 03-career-strategy/02-resume-engineering/ 2>/dev/null || true
    cp 00-career-mastery/08-prompt-engineer/linkedin-optimizer.md 03-career-strategy/01-personal-branding/linkedin/ 2>/dev/null || true
    cp 00-career-mastery/08-prompt-engineer/salary-negotiation.md 04-interview-readiness/04-negotiation-hiring/salary/ 2>/dev/null || true
fi

echo "✓ Interview Readiness content migrated"
echo ""

# =============================================================================
# PHASE 12: Centralize Images
# =============================================================================
echo "PHASE 12: Centralizing images..."

# Find and copy all images
find . -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.webp" -o -name "*.svg" \) 2>/dev/null | while read file; do
    # Get the directory name for categorization
    dir_name=$(basename "$(dirname "$file")")
    # Copy to assets/images with a prefix indicating source
    base_name=$(basename "$file")
    cp "$file" "assets/images/$base_name" 2>/dev/null || true
done

# Copy from career mastery images folder
if [ -d "00-career-mastery/images" ]; then
    cp -r 00-career-mastery/images/* assets/images/ 2>/dev/null || true
fi

echo "✓ Images centralized"
echo ""

# =============================================================================
# PHASE 13: Convert Folder Names to Kebab-Case
# =============================================================================
echo "PHASE 13: Converting folder names to kebab-case..."

# Function to convert to kebab-case
to_kebab_case() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr '_' '-'
}

# Convert specific known folders that need it
declare -a folders_to_rename=(
    "00-career-mastery/14-Interview-Questions"
    "02-intermediate/05-Foundational-Containers"
)

for folder in "${folders_to_rename[@]}"; do
    if [ -d "$folder" ]; then
        new_name=$(to_kebab_case "$(basename "$folder")")
        parent_dir=$(dirname "$folder")
        if [ "$parent_dir/$new_name" != "$folder" ] && [ ! -d "$parent_dir/$new_name" ]; then
            mv "$folder" "$parent_dir/$new_name" 2>/dev/null || true
            echo "  Renamed: $folder -> $parent_dir/$new_name"
        fi
    fi
done

echo "✓ Folder names converted to kebab-case"
echo ""

# =============================================================================
# PHASE 14: Create README.md Files
# =============================================================================
echo "PHASE 14: Creating README.md files..."

# Create README for main tiers
cat > 01-foundation/readme.md << 'EOF'
# Foundation Tier

This tier covers the fundamental skills every DevOps engineer needs:

- **Linux Administration**: System management, permissions, scripting
- **Networking Architecture**: OSI model, IP addressing, troubleshooting
- **Version Control (Git)**: Workflows, branching strategies, GitHub Actions
- **Windows Automation**: PowerShell, WSL, system administration

## Prerequisites
None - start here if you're new to DevOps.

## Learning Path
1. Complete Linux Administration fundamentals
2. Move to Networking Architecture
3. Learn Git version control
4. Explore Windows automation (optional for Linux-focused roles)
EOF

cat > 02-core-engineering/readme.md << 'EOF'
# Core Engineering Tier

This tier covers the core technical skills for DevOps engineering:

- **Cloud (AWS)**: EC2, S3, Lambda, VPC, security
- **Infrastructure as Code**: Terraform, Ansible, Packer
- **Automation (Python)**: Scripting, boto3, system automation
- **Containers & Orchestration**: Docker, Kubernetes, Helm

## Prerequisites
Complete Foundation Tier or equivalent experience.

## Learning Path
1. Start with Cloud AWS fundamentals
2. Learn Infrastructure as Code with Terraform
3. Master Python automation
4. Deep dive into containers and Kubernetes
EOF

cat > 03-career-strategy/readme.md << 'EOF'
# Career Strategy Tier

This tier focuses on career development and professional growth:

- **Personal Branding**: GitHub profile, LinkedIn, portfolio
- **Resume Engineering**: ATS optimization, templates, examples
- **Soft Skills**: Communication, triage, prioritization

## When to Use
Work on this tier in parallel with technical learning.

## Key Resources
- Resume templates and examples
- Portfolio project guides
- Day-in-the-life simulations
EOF

cat > 04-interview-readiness/readme.md << 'EOF'
# Interview Readiness Tier

This tier prepares you for the DevOps interview process:

- **Technical Knowledge Base**: Flashcards, deep dives
- **Behavioral STAR Method**: Scenarios, templates
- **Live Coding Assessment**: Challenges, solutions
- **Negotiation & Hiring**: Salary, hiring process

## When to Use
Start preparing 4-6 weeks before interviews.

## Key Resources
- Technical flashcards (CSV format)
- STAR scenario templates
- Coding challenge solutions
- Salary negotiation guides
EOF

cat > assets/readme.md << 'EOF'
# Assets

Centralized resources for the DevOps study guide:

- **images**: All visual assets (PNG, JPG, GIF, SVG, WebP)
- **scripts**: Organized by language (bash, python, powershell)
- **templates**: Documentation templates, post-mortems

## Usage
Reference these assets from your learning materials using relative paths.
EOF

# Create README for subdirectories
for dir in 01-foundation/*/ 02-core-engineering/*/ 03-career-strategy/*/ 04-interview-readiness/*/; do
    if [ ! -f "$dir/readme.md" ]; then
        dir_name=$(basename "$dir")
        cat > "$dir/readme.md" << EOF
# $dir_name

Content for this section is being organized.

## Overview
This folder contains resources and learning materials for $dir_name.

## Status
Content migration in progress.
EOF
    fi
done

echo "✓ README.md files created"
echo ""

# =============================================================================
# PHASE 15: Cleanup and Verification
# =============================================================================
echo "PHASE 15: Cleanup and verification..."

# Remove duplicate resume files (keep only professional versions in new location)
if [ -d "00-career-mastery/07-resume-engineering/resources/devops-resume-ganil-batistpdf" ]; then
    # Keep only the main PDF files, remove duplicates
    rm -f "00-career-mastery/07-resume-engineering/resources/devops-resume-ganil-batistpdf/devops-resume.docx" 2>/dev/null || true
    rm -f "00-career-mastery/07-resume-engineering/resources/devops-resume-ganil-batistpdf/devops-resume-ganil-batist.docx" 2>/dev/null || true
fi

# Verify no empty folders in new structure
echo ""
echo "Checking for empty folders in new structure..."
find 01-foundation 02-core-engineering 03-career-strategy 04-interview-readiness assets -type d -empty 2>/dev/null | while read empty_dir; do
    echo "  Warning: Empty folder found: $empty_dir"
    # Create a placeholder readme
    echo "# $(basename "$empty_dir")" > "$empty_dir/readme.md"
    echo "  Created placeholder readme.md"
done

echo ""
echo "=== Reorganization Complete ==="
echo ""
echo "New Structure:"
echo "├── 01-foundation/          (Linux, Networking, Git, Windows)"
echo "├── 02-core-engineering/    (AWS, Terraform, Python, Containers)"
echo "├── 03-career-strategy/     (Branding, Resume, Soft Skills)"
echo "├── 04-interview-readiness/ (Technical, Behavioral, Coding, Negotiation)"
echo "└── assets/                 (Images, Scripts, Templates)"
echo ""
echo "Next Steps:"
echo "1. Review the new structure"
echo "2. Verify all content has been migrated correctly"
echo "3. Update any broken links or references"
echo "4. Archive or remove old folder structure when ready"
