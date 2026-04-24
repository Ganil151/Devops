import os
import shutil

base_path = r"C:\Users\Ganil\Documents\Devops\2-Intermediate\02-Phase-2"

mapping = {
    "01-Automation": "Part-1-Scripting-Advanced",
    "02-Configuration-Tools": "Part-2-Config-Management",
    "03-CI-CD": "Part-3-Pipeline-Engineering",
    "04-Cloud-Engineering": "Part-4-Cloud-Platforms",
    "05-Prompt-Engineering": "Part-5-AI-Operations",
    "06-FinOps-Cost-as-Code": "Part-6-Cost-Management",
    "06-Monitoring-and-Alerting": "Part-7-Observability",
    "07-GitOps-ArgoCD": "Part-8-GitOps-Advanced",
    "08-Compliance-as-Code-Implementation": "Part-9-Policy-Enforcement",
    "09-Container-Security-Scanning-CI-CD": "Part-10-Security-Automation",
    "11-Edge-Computing-K3s": "Part-11-Edge-Platforms",
    "12-Serverless-IaC": "Part-12-Serverless-Tools"
}

print(f"Starting reorganization in {base_path}...")

if not os.path.exists(base_path):
    print(f"Error: {base_path} does not exist.")
    exit(1)

# List current directories
for item in os.listdir(base_path):
    src = os.path.join(base_path, item)
    if os.path.isdir(src):
        if item in mapping:
            dst_name = mapping[item]
            dst = os.path.join(base_path, dst_name)
            try:
                print(f"Renaming '{item}' to '{dst_name}'...")
                os.rename(src, dst)
            except Exception as e:
                print(f"Error renaming {item}: {e}")
        else:
            print(f"Skipping '{item}' (Not in mapping)")

# Create a README for the Phase if it doesn't exist or update it
readme_path = os.path.join(base_path, "README.md")
readme_content = """# Phase 2: Automation & IaC

This phase focuses on advanced automation, infrastructure as code, and modern DevOps practices.

## Modules

- **Part 1: Scripting Advanced** (Formerly 01-Automation)
- **Part 2: Config Management** (Formerly 02-Configuration-Tools)
- **Part 3: Pipeline Engineering** (Formerly 03-CI-CD)
- **Part 4: Cloud Platforms** (Formerly 04-Cloud-Engineering)
- **Part 5: AI Operations** (Formerly 05-Prompt-Engineering)
- **Part 6: Cost Management** (Formerly 06-FinOps-Cost-as-Code)
- **Part 7: Observability** (Formerly 06-Monitoring-and-Alerting)
- **Part 8: GitOps Advanced** (Formerly 07-GitOps-ArgoCD)
- **Part 9: Policy Enforcement** (Formerly 08-Compliance-as-Code-Implementation)
- **Part 10: Security Automation** (Formerly 09-Container-Security-Scanning-CI-CD)
- **Part 11: Edge Platforms** (Formerly 11-Edge-Computing-K3s)
- **Part 12: Serverless Tools** (Formerly 12-Serverless-IaC)

"""

with open(readme_path, "w") as f:
    f.write(readme_content)

print("Reorganization complete.")
