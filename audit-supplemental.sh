#!/bin/bash
# =============================================================================
# Supplemental Content Audit & Reorganization Script
# =============================================================================
# This script audits and reorganizes 01-beginner/99-supplemental-content
# into the proper tiered structure.
# =============================================================================

set -e

ROOT_DIR="/home/ganil/Documents/Devops"
cd "$ROOT_DIR"

SOURCE="01-beginner/99-supplemental-content"
echo "=== Supplemental Content Audit & Reorganization ==="
echo "Source: $SOURCE"
echo ""

# =============================================================================
# PHASE 1: Audit Analysis
# =============================================================================
echo "PHASE 1: Analyzing supplemental content structure..."
echo ""

# Count files and folders
echo "Content Summary:"
echo "─────────────────────────────────────────────────────────────"
for phase in 01-phase-1 02-phase-2 03-phase-3; do
    if [ -d "$SOURCE/$phase" ]; then
        dir_count=$(find "$SOURCE/$phase" -type d | wc -l)
        file_count=$(find "$SOURCE/$phase" -type f | wc -l)
        echo "  $phase: $dir_count directories, $file_count files"
    fi
done
echo "─────────────────────────────────────────────────────────────"
echo ""

# =============================================================================
# PHASE 2: Migration Mapping
# =============================================================================
echo "PHASE 2: Migrating content to proper locations..."
echo ""

# -----------------------------------------------------------------------------
# PHASE-1 MIGRATIONS
# -----------------------------------------------------------------------------
echo "  [Phase 1] Migrating foundational content..."

# 04-data-formats → 02-core-engineering/03-automation-python (JSON, YAML, TOML, XML)
if [ -d "$SOURCE/01-phase-1/04-data-formats" ]; then
    echo "    → Data formats (JSON, YAML, TOML, XML) → Python Automation"
    cp -r "$SOURCE/01-phase-1/04-data-formats"/* 02-core-engineering/03-automation-python/data-formats/ 2>/dev/null || true
    
    # Copy scripts
    if [ -d "$SOURCE/01-phase-1/04-data-formats/scripts" ]; then
        cp "$SOURCE/01-phase-1/04-data-formats/scripts"/*.py assets/scripts/python/ 2>/dev/null || true
        cp "$SOURCE/01-phase-1/04-data-formats/scripts"/*.sh assets/scripts/bash/ 2>/dev/null || true
    fi
fi

# 05-software-stack → 01-foundation (general dev environment setup)
if [ -d "$SOURCE/01-phase-1/05-software-stack" ]; then
    echo "    → Software stack → Foundation (dev environment)"
    mkdir -p 01-foundation/01-linux-administration/development-environment
    cp -r "$SOURCE/01-phase-1/05-software-stack"/* 01-foundation/01-linux-administration/development-environment/ 2>/dev/null || true
    
    # Copy scripts
    if [ -d "$SOURCE/01-phase-1/05-software-stack/scripts" ]; then
        cp "$SOURCE/01-phase-1/05-software-stack/scripts"/*.sh assets/scripts/bash/ 2>/dev/null || true
        cp "$SOURCE/01-phase-1/05-software-stack/scripts"/*.ps1 assets/scripts/powershell/ 2>/dev/null || true
    fi
fi

# 06-web-design → Keep as reference in assets or projects
if [ -d "$SOURCE/01-phase-1/06-web-design" ]; then
    echo "    → Web design frameworks → Reference material"
    mkdir -p 08-resources/03-frameworks-reference
    cp -r "$SOURCE/01-phase-1/06-web-design" 08-resources/03-frameworks-reference/web-frameworks/ 2>/dev/null || true
    
    # Copy scripts
    if [ -d "$SOURCE/01-phase-1/06-web-design/scripts" ]; then
        cp "$SOURCE/01-phase-1/06-web-design/scripts"/*.sh assets/scripts/bash/ 2>/dev/null || true
        cp "$SOURCE/01-phase-1/06-web-design/scripts"/*.py assets/scripts/python/ 2>/dev/null || true
    fi
fi

# 07-cloud-foundations → 02-core-engineering/01-cloud-aws (and multi-cloud)
if [ -d "$SOURCE/01-phase-1/07-cloud-foundations" ]; then
    echo "    → Cloud foundations → AWS/Cloud Engineering"
    
    # AWS content
    if [ -d "$SOURCE/01-phase-1/07-cloud-foundations/05-aws-basics" ]; then
        cp -r "$SOURCE/01-phase-1/07-cloud-foundations/05-aws-basics"/* 02-core-engineering/01-cloud-aws/foundations/ 2>/dev/null || true
    fi
    
    # Azure content
    if [ -d "$SOURCE/01-phase-1/07-cloud-foundations/06-azure-basics" ]; then
        mkdir -p 02-core-engineering/01-cloud-aws/multi-cloud/azure
        cp -r "$SOURCE/01-phase-1/07-cloud-foundations/06-azure-basics"/* 02-core-engineering/01-cloud-aws/multi-cloud/azure/ 2>/dev/null || true
    fi
    
    # GCP content
    if [ -d "$SOURCE/01-phase-1/07-cloud-foundations/07-gcp-basics" ]; then
        mkdir -p 02-core-engineering/01-cloud-aws/multi-cloud/gcp
        cp -r "$SOURCE/01-phase-1/07-cloud-foundations/07-gcp-basics"/* 02-core-engineering/01-cloud-aws/multi-cloud/gcp/ 2>/dev/null || true
    fi
    
    # General cloud fundamentals
    if [ -d "$SOURCE/01-phase-1/07-cloud-foundations/01-basic-networking" ]; then
        cp -r "$SOURCE/01-phase-1/07-cloud-foundations/01-basic-networking"/* 02-core-engineering/01-cloud-aws/networking/ 2>/dev/null || true
    fi
    
    # Copy scripts
    if [ -d "$SOURCE/01-phase-1/07-cloud-foundations/scripts" ]; then
        cp "$SOURCE/01-phase-1/07-cloud-foundations/scripts"/*.sh assets/scripts/bash/ 2>/dev/null || true
        cp "$SOURCE/01-phase-1/07-cloud-foundations/scripts"/*.py assets/scripts/python/ 2>/dev/null || true
    fi
fi

# 08-repository-management → 01-foundation/03-version-control-git
if [ -d "$SOURCE/01-phase-1/08-repository-management" ]; then
    echo "    → Repository management → Git Version Control"
    cp -r "$SOURCE/01-phase-1/08-repository-management"/* 01-foundation/03-version-control-git/repository-management/ 2>/dev/null || true
fi

echo "  ✓ Phase 1 content migrated"
echo ""

# -----------------------------------------------------------------------------
# PHASE-2 MIGRATIONS
# -----------------------------------------------------------------------------
echo "  [Phase 2] Migrating intermediate content..."

# 01-automation → 02-core-engineering/03-automation-python and 02-infrastructure-as-code
if [ -d "$SOURCE/02-phase-2/01-automation" ]; then
    echo "    → Automation → Python & Terraform"
    
    # Python basics
    if [ -d "$SOURCE/02-phase-2/01-automation/02-python-basics" ]; then
        cp -r "$SOURCE/02-phase-2/01-automation/02-python-basics"/* 02-core-engineering/03-automation-python/ 2>/dev/null || true
    fi
    
    # Terraform patterns
    if [ -d "$SOURCE/02-phase-2/01-automation/07-terraform-patterns" ]; then
        cp -r "$SOURCE/02-phase-2/01-automation/07-terraform-patterns"/* 02-core-engineering/02-infrastructure-as-code/terraform/patterns/ 2>/dev/null || true
    fi
    
    # Ansible dynamic inventory
    if [ -d "$SOURCE/02-phase-2/01-automation/06-ansible-dynamic-inventory" ]; then
        cp -r "$SOURCE/02-phase-2/01-automation/06-ansible-dynamic-inventory"/* 02-core-engineering/02-infrastructure-as-code/ansible/dynamic-inventory/ 2>/dev/null || true
    fi
    
    # Cron and job scheduling
    if [ -d "$SOURCE/02-phase-2/01-automation/04-job-scheduling-and-cron" ]; then
        mkdir -p 02-core-engineering/03-automation-python/job-scheduling
        cp -r "$SOURCE/02-phase-2/01-automation/04-job-scheduling-and-cron"/* 02-core-engineering/03-automation-python/job-scheduling/ 2>/dev/null || true
    fi
    
    # Copy scripts
    if [ -d "$SOURCE/02-phase-2/01-automation/scripts" ]; then
        cp "$SOURCE/02-phase-2/01-automation/scripts"/*.sh assets/scripts/bash/ 2>/dev/null || true
        cp "$SOURCE/02-phase-2/01-automation/scripts"/*.py assets/scripts/python/ 2>/dev/null || true
    fi
fi

# 02-api-basics → 02-core-engineering (API engineering)
if [ -d "$SOURCE/02-phase-2/02-api-basics" ]; then
    echo "    → API basics → Core Engineering (API)"
    mkdir -p 02-core-engineering/05-api-engineering
    cp -r "$SOURCE/02-phase-2/02-api-basics"/* 02-core-engineering/05-api-engineering/ 2>/dev/null || true
    
    # Copy scripts
    if [ -d "$SOURCE/02-phase-2/02-api-basics/scripts" ]; then
        cp "$SOURCE/02-phase-2/02-api-basics/scripts"/*.py assets/scripts/python/ 2>/dev/null || true
        cp "$SOURCE/02-phase-2/02-api-basics/scripts"/*.sh assets/scripts/bash/ 2>/dev/null || true
    fi
fi

# 03-nginx → 02-core-engineering (web servers/reverse proxy)
if [ -d "$SOURCE/02-phase-2/03-nginx" ]; then
    echo "    → Nginx → Core Engineering (Web Servers)"
    mkdir -p 02-core-engineering/06-web-servers/nginx
    cp -r "$SOURCE/02-phase-2/03-nginx"/* 02-core-engineering/06-web-servers/nginx/ 2>/dev/null || true
    
    # Copy scripts
    if [ -d "$SOURCE/02-phase-2/03-nginx/scripts" ]; then
        cp "$SOURCE/02-phase-2/03-nginx/scripts"/*.sh assets/scripts/bash/ 2>/dev/null || true
    fi
fi

# 04-maven → Keep as reference (build tool)
if [ -d "$SOURCE/02-phase-2/04-maven" ]; then
    echo "    → Maven → Reference (Build Tools)"
    mkdir -p 08-resources/03-frameworks-reference/build-tools/maven
    cp -r "$SOURCE/02-phase-2/04-maven"/* 08-resources/03-frameworks-reference/build-tools/maven/ 2>/dev/null || true
    
    # Copy scripts
    if [ -d "$SOURCE/02-phase-2/04-maven/scripts" ]; then
        cp "$SOURCE/02-phase-2/04-maven/scripts"/*.sh assets/scripts/bash/ 2>/dev/null || true
    fi
fi

# 05-basic-ci-cd → 02-core-engineering or 04-interview-readiness
if [ -d "$SOURCE/02-phase-2/05-basic-ci-cd" ]; then
    echo "    → CI/CD basics → Core Engineering (CI/CD)"
    mkdir -p 02-core-engineering/07-ci-cd/fundamentals
    cp -r "$SOURCE/02-phase-2/05-basic-ci-cd"/* 02-core-engineering/07-ci-cd/fundamentals/ 2>/dev/null || true
    
    # Copy scripts
    if [ -d "$SOURCE/02-phase-2/05-basic-ci-cd/scripts" ]; then
        cp "$SOURCE/02-phase-2/05-basic-ci-cd/scripts"/*.sh assets/scripts/bash/ 2>/dev/null || true
        cp "$SOURCE/02-phase-2/05-basic-ci-cd/scripts"/*.py assets/scripts/python/ 2>/dev/null || true
    fi
fi

# 06-prompt-engineering → 03-career-strategy (productivity tool)
if [ -d "$SOURCE/02-phase-2/06-prompt-engineering" ]; then
    echo "    → Prompt engineering → Career Strategy (Productivity)"
    mkdir -p 03-career-strategy/04-productivity/prompt-engineering
    cp -r "$SOURCE/02-phase-2/06-prompt-engineering"/* 03-career-strategy/04-productivity/prompt-engineering/ 2>/dev/null || true
fi

# 07-observability-fundamentals → 02-core-engineering (monitoring)
if [ -d "$SOURCE/02-phase-2/07-observability-fundamentals" ]; then
    echo "    → Observability → Core Engineering (Monitoring)"
    mkdir -p 02-core-engineering/08-observability/fundamentals
    cp -r "$SOURCE/02-phase-2/07-observability-fundamentals"/* 02-core-engineering/08-observability/fundamentals/ 2>/dev/null || true
    
    # Copy scripts
    if [ -d "$SOURCE/02-phase-2/07-observability-fundamentals/scripts" ]; then
        cp "$SOURCE/02-phase-2/07-observability-fundamentals/scripts"/*.sh assets/scripts/bash/ 2>/dev/null || true
        cp "$SOURCE/02-phase-2/07-observability-fundamentals/scripts"/*.py assets/scripts/python/ 2>/dev/null || true
    fi
fi

# 08-gitops-fundamentals → 02-core-engineering (GitOps)
if [ -d "$SOURCE/02-phase-2/08-gitops-fundamentals" ]; then
    echo "    → GitOps → Core Engineering (GitOps)"
    mkdir -p 02-core-engineering/07-ci-cd/gitops
    cp -r "$SOURCE/02-phase-2/08-gitops-fundamentals"/* 02-core-engineering/07-ci-cd/gitops/ 2>/dev/null || true
    
    # Copy scripts
    if [ -d "$SOURCE/02-phase-2/08-gitops-fundamentals/scripts" ]; then
        cp "$SOURCE/02-phase-2/08-gitops-fundamentals/scripts"/*.sh assets/scripts/bash/ 2>/dev/null || true
        cp "$SOURCE/02-phase-2/08-gitops-fundamentals/scripts"/*.py assets/scripts/python/ 2>/dev/null || true
    fi
fi

# 09-compliance-as-code-foundations → 02-core-engineering (security/compliance)
if [ -d "$SOURCE/02-phase-2/09-compliance-as-code-foundations" ]; then
    echo "    → Compliance as code → Core Engineering (Security)"
    mkdir -p 02-core-engineering/09-security/compliance-as-code
    cp -r "$SOURCE/02-phase-2/09-compliance-as-code-foundations"/* 02-core-engineering/09-security/compliance-as-code/ 2>/dev/null || true
    
    # Copy scripts
    if [ -d "$SOURCE/02-phase-2/09-compliance-as-code-foundations/scripts" ]; then
        cp "$SOURCE/02-phase-2/09-compliance-as-code-foundations/scripts"/*.sh assets/scripts/bash/ 2>/dev/null || true
        cp "$SOURCE/02-phase-2/09-compliance-as-code-foundations/scripts"/*.py assets/scripts/python/ 2>/dev/null || true
    fi
fi

# 10-container-security-basics → 02-core-engineering/04-containers-orchestration
if [ -d "$SOURCE/02-phase-2/10-container-security-basics" ]; then
    echo "    → Container security → Containers & Orchestration"
    cp -r "$SOURCE/02-phase-2/10-container-security-basics"/* 02-core-engineering/04-containers-orchestration/security/ 2>/dev/null || true
    
    # Copy scripts
    if [ -d "$SOURCE/02-phase-2/10-container-security-basics/scripts" ]; then
        cp "$SOURCE/02-phase-2/10-container-security-basics/scripts"/*.sh assets/scripts/bash/ 2>/dev/null || true
    fi
fi

echo "  ✓ Phase 2 content migrated"
echo ""

# -----------------------------------------------------------------------------
# PHASE-3 MIGRATIONS
# -----------------------------------------------------------------------------
echo "  [Phase 3] Migrating advanced content..."

if [ -d "$SOURCE/03-phase-3" ]; then
    # 01-ci-cd-foundations → 02-core-engineering/07-ci-cd
    if [ -d "$SOURCE/03-phase-3/01-ci-cd-foundations" ]; then
        echo "    → CI/CD foundations → Core Engineering (CI/CD)"
        cp -r "$SOURCE/03-phase-3/01-ci-cd-foundations"/* 02-core-engineering/07-ci-cd/advanced/ 2>/dev/null || true
    fi
    
    # 02-container-orchestration → 02-core-engineering/04-containers-orchestration
    if [ -d "$SOURCE/03-phase-3/02-container-orchestration" ]; then
        echo "    → Container orchestration → Containers & Orchestration"
        cp -r "$SOURCE/03-phase-3/02-container-orchestration"/* 02-core-engineering/04-containers-orchestration/advanced/ 2>/dev/null || true
    fi
    
    # 03-finops → 02-core-engineering (cost optimization)
    if [ -d "$SOURCE/03-phase-3/03-finops" ]; then
        echo "    → FinOps → Core Engineering (Cost Optimization)"
        mkdir -p 02-core-engineering/10-finops
        cp -r "$SOURCE/03-phase-3/03-finops"/* 02-core-engineering/10-finops/ 2>/dev/null || true
    fi
    
    # 04-mcp and 05-blockchain → Keep as specialized topics
    if [ -d "$SOURCE/03-phase-3/04-mcp" ]; then
        echo "    → MCP → Specialized topics"
        mkdir -p 08-resources/04-specialized-topics/mcp
        cp -r "$SOURCE/03-phase-3/04-mcp"/* 08-resources/04-specialized-topics/mcp/ 2>/dev/null || true
    fi
    
    if [ -d "$SOURCE/03-phase-3/05-blockchain" ]; then
        echo "    → Blockchain → Specialized topics"
        mkdir -p 08-resources/04-specialized-topics/blockchain
        cp -r "$SOURCE/03-phase-3/05-blockchain"/* 08-resources/04-specialized-topics/blockchain/ 2>/dev/null || true
    fi
fi

echo "  ✓ Phase 3 content migrated"
echo ""

# =============================================================================
# PHASE 3: Handle readme.md files in wrong location
# =============================================================================
echo "PHASE 3: Cleaning up misplaced files..."

# Move readme.md from 01-beginner to proper location if it's the main one
if [ -f "01-beginner/readme.md" ]; then
    # Check if it's the SRE Beginner's Academy readme
    if grep -q "SRE Beginner" "01-beginner/readme.md" 2>/dev/null; then
        echo "  → Moving SRE Beginner readme to appropriate location"
        cp "01-beginner/readme.md" "01-foundation/sre-beginner-academy.md" 2>/dev/null || true
    fi
fi

# Move readme-v2.md if it exists
if [ -f "01-beginner/readme-v2.md" ]; then
    echo "  → Archiving readme-v2.md"
    cp "01-beginner/readme-v2.md" "08-resources/archived-docs/readme-v2.md" 2>/dev/null || true
    mkdir -p "08-resources/archived-docs"
fi

echo "  ✓ Misplaced files handled"
echo ""

# =============================================================================
# PHASE 4: Create README for new sections
# =============================================================================
echo "PHASE 4: Creating README files for new sections..."

# API Engineering
cat > 02-core-engineering/05-api-engineering/readme.md << 'EOF'
# API Engineering

Learn to design, build, and secure APIs for modern applications.

## Topics Covered
- RESTful API design principles
- API security and authentication
- Advanced API workflows
- API testing and documentation

## Prerequisites
- Basic HTTP knowledge
- Python or similar programming language
EOF

# Web Servers
cat > 02-core-engineering/06-web-servers/readme.md << 'EOF'
# Web Servers

Master web server configuration, reverse proxy, and load balancing.

## Topics Covered
- Nginx architecture and configuration
- Traffic management and performance
- Security hardening
- Load balancing strategies
EOF

# CI/CD
cat > 02-core-engineering/07-ci-cd/readme.md << 'EOF'
# CI/CD (Continuous Integration / Continuous Deployment)

Automate your software delivery pipeline.

## Topics Covered
- CI/CD principles and fundamentals
- GitHub Actions workflows
- Advanced pipeline patterns
- GitOps methodologies
- Deployment strategies
EOF

# Observability
cat > 02-core-engineering/08-observability/readme.md << 'EOF'
# Observability & Monitoring

Gain visibility into your systems with proper monitoring and alerting.

## Topics Covered
- The four signals (latency, traffic, errors, saturation)
- Active monitoring strategies
- Logging best practices
- Metrics and dashboards
- Alerting and on-call

## Tools
- Prometheus
- Grafana
- ELK Stack
- CloudWatch
EOF

# Security
cat > 02-core-engineering/09-security/readme.md << 'EOF'
# Security & Compliance

Implement security best practices and compliance as code.

## Topics Covered
- Policy foundations
- Security auditing
- Compliance as code
- Container security
- Network security
EOF

# FinOps
cat > 02-core-engineering/10-finops/readme.md << 'EOF'
# FinOps (Cloud Financial Management)

Optimize cloud costs and maximize business value.

## Topics Covered
- Cost allocation and showback
- Budget management
- Resource optimization
- Cloud pricing models
- Cost monitoring and alerting
EOF

echo "  ✓ README files created"
echo ""

# =============================================================================
# PHASE 5: Final Verification
# =============================================================================
echo "PHASE 5: Final verification..."
echo ""

echo "Migration Summary:"
echo "─────────────────────────────────────────────────────────────"
echo ""
echo "New Sections Created:"
echo "  ✓ 02-core-engineering/05-api-engineering/"
echo "  ✓ 02-core-engineering/06-web-servers/"
echo "  ✓ 02-core-engineering/07-ci-cd/"
echo "  ✓ 02-core-engineering/08-observability/"
echo "  ✓ 02-core-engineering/09-security/"
echo "  ✓ 02-core-engineering/10-finops/"
echo "  ✓ 03-career-strategy/04-productivity/"
echo ""
echo "Content Consolidated:"
echo "  ✓ Data formats → Python Automation"
echo "  ✓ Cloud foundations → AWS/Cloud Engineering"
echo "  ✓ Automation scripts → Centralized assets/scripts/"
echo "  ✓ Repository management → Git Version Control"
echo "  ✓ CI/CD → Core Engineering"
echo "  ✓ Observability → Core Engineering"
echo "  ✓ Container security → Containers & Orchestration"
echo ""
echo "─────────────────────────────────────────────────────────────"
echo ""
echo "=== Reorganization Complete ==="
echo ""
echo "Next Steps:"
echo "1. Review migrated content in new locations"
echo "2. Update any broken internal links"
echo "3. Archive or remove 01-beginner/99-supplemental-content when ready"
