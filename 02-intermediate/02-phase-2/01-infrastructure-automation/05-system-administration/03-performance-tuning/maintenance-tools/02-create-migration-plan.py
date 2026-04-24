#!/usr/bin/env python3
"""
DevOps Directory Reorganization - Migration Script
Creates new directory structure and maps old paths to new paths.
DOES NOT MOVE FILES - only creates structure and generates migration plan.
"""

import os
import json
from pathlib import Path
from datetime import datetime

class DevOpsMigrationPlanner:
    def __init__(self, root_path):
        self.root_path = Path(root_path)
        self.migration_map = []
        self.new_structure = {}
        
    def create_new_structure_map(self):
        """
        Define the new directory structure with Part layers.
        Returns mapping of old paths to new paths.
        """
        
        # Format: (old_path, new_path, description)
        mappings = []
        
        # ========================================================================
        # 1-BEGINNER MAPPINGS
        # ========================================================================
        
        # Phase 1 - Foundations
        mappings.extend([
            ("1-Beginner/01-Phase-1/01-Networking", "1-Beginner/Phase-1-Foundations/Part-1-Networking", "Network fundamentals"),
            ("1-Beginner/01-Phase-1/02-Linux", "1-Beginner/Phase-1-Foundations/Part-2-Linux", "Linux basics"),
            ("1-Beginner/01-Phase-1/03-Windows-Basics", "1-Beginner/Phase-1-Foundations/Part-3-Windows", "Windows fundamentals"),
            ("1-Beginner/01-Phase-1/04-Data-Formats", "1-Beginner/Phase-1-Foundations/Part-4-Data-Formats", "JSON, YAML, XML"),
            ("1-Beginner/01-Phase-1/05-Software-Stack", "1-Beginner/Phase-1-Foundations/Part-5-Software-Stack", "Application stacks"),
            ("1-Beginner/01-Phase-1/06-Web-Design", "1-Beginner/Phase-1-Foundations/Part-6-Web-Design", "Web basics"),
            ("1-Beginner/01-Phase-1/07-Cloud-Foundations", "1-Beginner/Phase-1-Foundations/Part-7-Cloud-Basics", "Cloud intro"),
        ])
        
        # Phase 2 - Core Skills
        mappings.extend([
            ("1-Beginner/02-Phase-2/01-Automation", "1-Beginner/Phase-2-Core-Skills/Part-1-Automation-Basics", "Shell scripting intro"),
            ("1-Beginner/02-Phase-2/02-API-Basics", "1-Beginner/Phase-2-Core-Skills/Part-2-API-Fundamentals", "REST APIs"),
            ("1-Beginner/02-Phase-2/03-Nginx", "1-Beginner/Phase-2-Core-Skills/Part-3-Web-Servers", "Nginx basics"),
            ("1-Beginner/02-Phase-2/04-Maven", "1-Beginner/Phase-2-Core-Skills/Part-4-Build-Tools", "Maven fundamentals"),
            ("1-Beginner/02-Phase-2/05-Basic-CI-CD", "1-Beginner/Phase-2-Core-Skills/Part-5-CI-CD-Intro", "GitHub Actions"),
            ("1-Beginner/02-Phase-2/06-Prompt-Engineering", "1-Beginner/Phase-2-Core-Skills/Part-6-AI-Basics", "AI fundamentals"),
            ("1-Beginner/02-Phase-2/07-Observability-Fundamentals", "1-Beginner/Phase-2-Core-Skills/Part-7-Monitoring-Basics", "MELT intro"),
            ("1-Beginner/02-Phase-2/08-GitOps-Fundamentals", "1-Beginner/Phase-2-Core-Skills/Part-8-GitOps-Intro", "GitOps basics"),
            ("1-Beginner/02-Phase-2/09-Compliance-as-Code-Foundations", "1-Beginner/Phase-2-Core-Skills/Part-9-Compliance-Basics", "Policy intro"),
            ("1-Beginner/02-Phase-2/10-Container-Security-Basics", "1-Beginner/Phase-2-Core-Skills/Part-10-Security-Fundamentals", "Container security"),
        ])
        
        # Phase 3 - First Advanced
        mappings.extend([
            ("1-Beginner/03-Phase-3/01-Container-Orchestration", "1-Beginner/Phase-3-First-Advanced/Part-1-Kubernetes-Basics", "Docker & K8s intro"),
            ("1-Beginner/03-Phase-3/02-FinOps", "1-Beginner/Phase-3-First-Advanced/Part-2-Cost-Awareness", "Cloud cost basics"),
            ("1-Beginner/03-Phase-3/03-MCP", "1-Beginner/Phase-3-First-Advanced/Part-3-AI-Integration", "MCP basics"),
            ("1-Beginner/03-Phase-3/04-Blockchain", "1-Beginner/Phase-3-First-Advanced/Part-4-Web3-Basics", "Blockchain intro"),
        ])
        
        # ========================================================================
        # 2-INTERMEDIATE MAPPINGS
        # ========================================================================
        
        # Phase 1 - Deepening
        mappings.extend([
            ("2-Intermediate/01-Phase-1/01-Networking", "2-Intermediate/Phase-1-Deepening/Part-1-Advanced-Networking", "VPC, VPN, LB"),
            ("2-Intermediate/01-Phase-1/02-Linux", "2-Intermediate/Phase-1-Deepening/Part-2-Linux-Administration", "System admin"),
            ("2-Intermediate/01-Phase-1/03-Runbooks-Procedures", "2-Intermediate/Phase-1-Deepening/Part-3-Operations-Procedures", "Runbooks & SOPs"),
            ("2-Intermediate/01-Phase-1/04-Repository-Management", "2-Intermediate/Phase-1-Deepening/Part-4-Version-Control", "Git, GitLab"),
            ("2-Intermediate/01-Phase-1/05-Databases", "2-Intermediate/Phase-1-Deepening/Part-5-Data-Management", "DB operations"),
        ])
        
        # Phase 2 - Automation & IaC
        mappings.extend([
            ("2-Intermediate/02-Phase-2/01-Automation", "2-Intermediate/Phase-2-Automation-IaC/Part-1-Scripting-Advanced", "Advanced scripting"),
            ("2-Intermediate/02-Phase-2/02-Configuration-Tools", "2-Intermediate/Phase-2-Automation-IaC/Part-2-Config-Management", "Ansible, Terraform"),
            ("2-Intermediate/02-Phase-2/03-CI-CD", "2-Intermediate/Phase-2-Automation-IaC/Part-3-Pipeline-Engineering", "Jenkins, GitLab CI"),
            ("2-Intermediate/02-Phase-2/04-Cloud-Engineering", "2-Intermediate/Phase-2-Automation-IaC/Part-4-Cloud-Platforms", "AWS, GCP, Azure"),
            ("2-Intermediate/02-Phase-2/05-Prompt-Engineering", "2-Intermediate/Phase-2-Automation-IaC/Part-5-AI-Operations", "AI automation"),
            ("2-Intermediate/02-Phase-2/06-FinOps-Cost-as-Code", "2-Intermediate/Phase-2-Automation-IaC/Part-6-Cost-Management", "Cost optimization"),
            ("2-Intermediate/02-Phase-2/06-Monitoring-and-Alerting", "2-Intermediate/Phase-2-Automation-IaC/Part-7-Observability", "Monitoring tools"),
            ("2-Intermediate/02-Phase-2/07-GitOps-ArgoCD", "2-Intermediate/Phase-2-Automation-IaC/Part-8-GitOps-Advanced", "ArgoCD"),
            ("2-Intermediate/02-Phase-2/08-Compliance-as-Code-Implementation", "2-Intermediate/Phase-2-Automation-IaC/Part-9-Policy-Enforcement", "OPA, policies"),
            ("2-Intermediate/02-Phase-2/09-Container-Security-Scanning-CI-CD", "2-Intermediate/Phase-2-Automation-IaC/Part-10-Security-Automation", "Security scanning"),
            ("2-Intermediate/02-Phase-2/11-Edge-Computing-K3s", "2-Intermediate/Phase-2-Automation-IaC/Part-11-Edge-Platforms", "K3s, edge"),
            ("2-Intermediate/02-Phase-2/12-Serverless-IaC", "2-Intermediate/Phase-2-Automation-IaC/Part-12-Serverless-Tools", "Lambda, functions"),
        ])
        
        # Phase 3 - Specialization
        mappings.extend([
            ("2-Intermediate/03-Phase-3/01-Container-Orchestration", "2-Intermediate/Phase-3-Specialization/Part-1-K8s-Advanced", "K8s deep dive"),
            ("2-Intermediate/03-Phase-3/02-Observability-Foundations", "2-Intermediate/Phase-3-Specialization/Part-2-Monitoring-Advanced", "Prometheus, Grafana"),
            ("2-Intermediate/03-Phase-3/03-API-Gateways-Security", "2-Intermediate/Phase-3-Specialization/Part-3-API-Management", "API gateways"),
            ("2-Intermediate/03-Phase-3/04-MCP", "2-Intermediate/Phase-3-Specialization/Part-4-AI-Platforms", "MCP intermediate"),
            ("2-Intermediate/03-Phase-3/05-Blockchain", "2-Intermediate/Phase-3-Specialization/Part-5-Web3-Operations", "Smart contracts"),
            ("2-Intermediate/03-Phase-3/06-FinOps", "2-Intermediate/Phase-3-Specialization/Part-6-Cost-Optimization", "FinOps practices"),
        ])
        
        # ========================================================================
        # 3-ADVANCED MAPPINGS
        # ========================================================================
        
        # Phase 1 - Enterprise
        mappings.extend([
            ("3-Advanced/01-Phase-1/01-Networking", "3-Advanced/Phase-1-Enterprise/Part-1-Global-Networks", "Multi-cloud networking"),
            ("3-Advanced/01-Phase-1/02-Automation", "3-Advanced/Phase-1-Enterprise/Part-2-Enterprise-Automation", "Enterprise patterns"),
            ("3-Advanced/01-Phase-1/03-Linux", "3-Advanced/Phase-1-Enterprise/Part-3-Systems-Performance", "Kernel tuning, eBPF"),
            ("3-Advanced/01-Phase-1/04-Container-Orchestration", "3-Advanced/Phase-1-Enterprise/Part-4-K8s-Operations", "Operators, CRDs"),
            ("3-Advanced/01-Phase-1/07-Security", "3-Advanced/Phase-1-Enterprise/Part-5-Security-Architecture", "DevSecOps"),
        ])
        
        # Phase 2 - Strategic (Grouped into logical Parts)
        # Group 1: Service Mesh
        mappings.extend([
            ("3-Advanced/02-Phase-2/05-Service-Mesh-Istio", "3-Advanced/Phase-2-Strategic/Part-1-Service-Mesh/01-Istio", "Istio deep dive"),
            ("3-Advanced/02-Phase-2/21-Service-Mesh-Security-mTLS-SPIFFE", "3-Advanced/Phase-2-Strategic/Part-1-Service-Mesh/02-Security-mTLS", "mTLS, SPIFFE"),
            ("3-Advanced/02-Phase-2/27-Service-Mesh-Observability-Kiali-Jaeger", "3-Advanced/Phase-2-Strategic/Part-1-Service-Mesh/03-Observability", "Kiali, Jaeger"),
        ])
        
        # Group 2: GitOps & Fleet Management
        mappings.extend([
            ("3-Advanced/02-Phase-2/05-GitOps", "3-Advanced/Phase-2-Strategic/Part-2-GitOps-Fleet/01-GitOps-Advanced", "GitOps patterns"),
            ("3-Advanced/02-Phase-2/24-Fleet-Management-ArgoCD-ApplicationSets", "3-Advanced/Phase-2-Strategic/Part-2-GitOps-Fleet/02-Fleet-Management", "ApplicationSets"),
        ])
        
        # Group 3: Multi-Cluster & Networking
        mappings.extend([
            ("3-Advanced/02-Phase-2/07-Multi-Cluster-Kubernetes", "3-Advanced/Phase-2-Strategic/Part-3-Multi-Cluster/01-Multi-Cluster-K8s", "Cluster federation"),
            ("3-Advanced/02-Phase-2/34-Advanced-K8s-Networking-Cilium", "3-Advanced/Phase-2-Strategic/Part-3-Multi-Cluster/02-Advanced-Networking", "Cilium, eBPF"),
        ])
        
        # Group 4: Platform Engineering
        mappings.extend([
            ("3-Advanced/02-Phase-2/13-Platform-Engineering-Backstage", "3-Advanced/Phase-2-Strategic/Part-4-Platform-Engineering/01-Backstage", "IDP platforms"),
            ("3-Advanced/02-Phase-2/14-Database-Reliability-DBRE", "3-Advanced/Phase-2-Strategic/Part-4-Platform-Engineering/02-DBRE", "Database SRE"),
        ])
        
        # Group 5: Security & Compliance
        mappings.extend([
            ("3-Advanced/02-Phase-2/15-Supply-Chain-Security", "3-Advanced/Phase-2-Strategic/Part-5-Security-Compliance/01-Supply-Chain", "SLSA, SBOM"),
            ("3-Advanced/02-Phase-2/12-Cloud-Compliance-and-Runtime-Security", "3-Advanced/Phase-2-Strategic/Part-5-Security-Compliance/02-Runtime-Security", "Cloud compliance"),
            ("3-Advanced/02-Phase-2/23-Advanced-Secret-Management-Vault", "3-Advanced/Phase-2-Strategic/Part-5-Security-Compliance/03-Secrets-Management", "Vault"),
            ("3-Advanced/02-Phase-2/25-K8s-Admission-Controllers-OPA", "3-Advanced/Phase-2-Strategic/Part-5-Security-Compliance/04-Admission-Control", "OPA, Gatekeeper"),
            ("3-Advanced/02-Phase-2/29-Automated-Security-Scanning", "3-Advanced/Phase-2-Strategic/Part-5-Security-Compliance/05-Security-Scanning", "SAST, DAST"),
            ("3-Advanced/02-Phase-2/22-Automated-Compliance-Auditing-Cloud-Custodian", "3-Advanced/Phase-2-Strategic/Part-5-Security-Compliance/06-Compliance-Auditing", "Cloud Custodian"),
        ])
        
        # Group 6: Observability Stack
        mappings.extend([
            ("3-Advanced/02-Phase-2/06-Observability", "3-Advanced/Phase-2-Strategic/Part-6-Observability-Stack/01-Observability", "Advanced monitoring"),
            ("3-Advanced/02-Phase-2/32-Cloud-Native-Logging-Loki-FluentBit", "3-Advanced/Phase-2-Strategic/Part-6-Observability-Stack/02-Logging", "Loki, FluentBit"),
        ])
        
        # Group 7: FinOps & Governance
        mappings.extend([
            ("3-Advanced/02-Phase-2/18-FinOps-K8s-Optimization", "3-Advanced/Phase-2-Strategic/Part-7-FinOps-Governance/01-K8s-Optimization", "K8s cost mgmt"),
            ("3-Advanced/02-Phase-2/33-Infrastructure-Cost-Governance-Infracost", "3-Advanced/Phase-2-Strategic/Part-7-FinOps-Governance/02-Cost-Governance", "Infracost"),
        ])
        
        # Group 8: Resilience Engineering
        mappings.extend([
            ("3-Advanced/02-Phase-2/19-Chaos-Engineering-Chaos-Mesh", "3-Advanced/Phase-2-Strategic/Part-8-Resilience/01-Chaos-Engineering", "Chaos Mesh"),
            ("3-Advanced/02-Phase-2/28-Cloud-Native-Backup-Velero", "3-Advanced/Phase-2-Strategic/Part-8-Resilience/02-Backup-DR", "Velero"),
            ("3-Advanced/02-Phase-2/17-Serverless-Incident-Management", "3-Advanced/Phase-2-Strategic/Part-8-Resilience/03-Incident-Management", "Incident response"),
        ])
        
        # Group 9: Advanced Automation
        mappings.extend([
            ("3-Advanced/02-Phase-2/01-Automation", "3-Advanced/Phase-2-Strategic/Part-9-Advanced-Automation/01-Automation", "Advanced patterns"),
            ("3-Advanced/02-Phase-2/30-Advanced-Terraform-Workflows", "3-Advanced/Phase-2-Strategic/Part-9-Advanced-Automation/02-Terraform-Advanced", "Terraform enterprise"),
            ("3-Advanced/02-Phase-2/31-Automated-Performance-Testing-Locust-k6", "3-Advanced/Phase-2-Strategic/Part-9-Advanced-Automation/03-Performance-Testing", "Load testing"),
            ("3-Advanced/02-Phase-2/26-Advanced-CICD-Patterns-GH-Actions", "3-Advanced/Phase-2-Strategic/Part-9-Advanced-Automation/04-CICD-Patterns", "GitHub Actions"),
            ("3-Advanced/02-Phase-2/16-Bare-Metal-Automation", "3-Advanced/Phase-2-Strategic/Part-9-Advanced-Automation/05-Bare-Metal", "Physical infra"),
        ])
        
        # Group 10: AI & Intelligent Operations
        mappings.extend([
            ("3-Advanced/02-Phase-2/10-AI-Driven-Operations-AIOps", "3-Advanced/Phase-2-Strategic/Part-10-AI-Operations/01-AIOps", "AI-driven ops"),
        ])
        
        # Group 11: Cloud Architecture
        mappings.extend([
            ("3-Advanced/02-Phase-2/11-Enterprise-Cloud", "3-Advanced/Phase-2-Strategic/Part-11-Cloud-Architecture/01-Enterprise-Cloud", "Multi-cloud"),
            ("3-Advanced/02-Phase-2/09-Microservices", "3-Advanced/Phase-2-Strategic/Part-11-Cloud-Architecture/02-Microservices", "Microservices"),
            ("3-Advanced/02-Phase-2/08-Identity-Governance", "3-Advanced/Phase-2-Strategic/Part-11-Cloud-Architecture/03-Identity-Governance", "IAM, RBAC"),
            ("3-Advanced/02-Phase-2/20-Advanced-Identity-Federation", "3-Advanced/Phase-2-Strategic/Part-11-Cloud-Architecture/04-Identity-Federation", "SSO, SAML"),
        ])
        
        # Phase 3 - Excellence
        mappings.extend([
            ("3-Advanced/03-Phase-3/11-Specialized-Tech", "3-Advanced/Phase-3-Excellence/Part-1-Specialized-Tech", "MLOps, Web3"),
            ("3-Advanced/03-Phase-3/12-Prompt-Engineering", "3-Advanced/Phase-3-Excellence/Part-2-AI-Engineering", "Agentic AI"),
            ("3-Advanced/03-Phase-3/13-MCP", "3-Advanced/Phase-3-Excellence/Part-3-MCP-Enterprise", "MCP at scale"),
            ("3-Advanced/03-Phase-3/14-Blockchain", "3-Advanced/Phase-3-Excellence/Part-4-Web3-Infrastructure", "Validator nodes"),
            ("3-Advanced/03-Phase-3/15-FinOps", "3-Advanced/Phase-3-Excellence/Part-5-Enterprise-FinOps", "Enterprise governance"),
            ("3-Advanced/03-Phase-3/16-Advanced-API-Architectures", "3-Advanced/Phase-3-Excellence/Part-6-API-Architecture", "gRPC, GraphQL"),
        ])
        
        return mappings
    
    def generate_migration_manifest(self, output_path):
        """Generate migration manifest showing all path changes"""
        
        mappings = self.create_new_structure_map()
        
        manifest = {
            'metadata': {
                'generated': datetime.now().isoformat(),
                'total_mappings': len(mappings),
                'root_path': str(self.root_path)
            },
            'mappings': []
        }
        
        for old_path, new_path, description in mappings:
            manifest['mappings'].append({
                'old_path': old_path,
                'new_path': new_path,
                'description': description,
                'exists': (self.root_path / old_path).exists()
            })
        
        # Save JSON manifest
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(manifest, f, indent=2)
        
        # Generate human-readable table
        md_path = output_path.replace('.json', '.md')
        with open(md_path, 'w', encoding='utf-8') as f:
            f.write(f"# DevOps Reorganization - Migration Manifest\n\n")
            f.write(f"**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\\n")
            f.write(f"**Total Migrations**: {len(mappings)}\\n\\n")
            
            # Group by tier
            for tier in ['1-Beginner', '2-Intermediate', '3-Advanced']:
                tier_mappings = [m for m in mappings if m[0].startswith(tier)]
                if tier_mappings:
                    f.write(f"## {tier} ({len(tier_mappings)} modules)\\n\\n")
                    f.write("| Old Path | New Path | Description | Status |\\n")
                    f.write("|----------|----------|-------------|--------|\\n")
                    for old_path, new_path, desc in tier_mappings:
                        exists = "✅" if (self.root_path / old_path).exists() else "❌"
                        f.write(f"| `{old_path}` | `{new_path}` | {desc} | {exists} |\\n")
                    f.write("\\n")
        
        print(f"[+] Migration manifest saved to: {output_path}")
        print(f"[+] Human-readable version: {md_path}")
        return manifest
    
    def create_directory_structure(self, dry_run=True):
        """Create new directory structure (dry run by default)"""
        
        mappings = self.create_new_structure_map()
        created = []
        
        for old_path, new_path, description in mappings:
            new_full_path = self.root_path / new_path
            
            if dry_run:
                print(f"[DRY RUN] Would create: {new_path}")
                created.append(str(new_path))
            else:
                if not new_full_path.exists():
                    new_full_path.mkdir(parents=True, exist_ok=True)
                    print(f"[CREATED] {new_path}")
                    created.append(str(new_path))
                else:
                    print(f"[EXISTS] {new_path}")
        
        return created


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        root_path = sys.argv[1]
    else:
        root_path = "C:/Users/Ganil/Documents/Devops"
    
    planner = DevOpsMigrationPlanner(root_path)
    
    print("[*] Generating migration manifest...")
    manifest = planner.generate_migration_manifest(
        os.path.join(root_path, "MIGRATION_MANIFEST.json")
    )
    
    print(f"\\n[+] Manifest generation complete!")
    print(f"    Total modules to migrate: {manifest['metadata']['total_mappings']}")
    
    print("\\n[*] This script only generates the migration plan.")
    print("    Files have NOT been moved yet.")
    print("    Review MIGRATION_MANIFEST.md before proceeding.")
