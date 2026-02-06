import os
from pathlib import Path

def get_rel_path(p):
    return os.path.relpath(p, "/home/gsmash/Documents/Devops")

def generate_reference():
    root = "/home/gsmash/Documents/Devops"
    
    # 1. Main Navigation links
    nav = [
        ("Tier 1: Beginner", "01-beginner/readme.md"),
        ("Tier 2: Intermediate", "02-intermediate/readme.md"),
        ("Tier 3: Advanced", "03-advanced/readme.md"),
        ("Projects Showcase", "04-projects-showcase/readme.md"),
        ("Labs and Simulations", "05-labs/readme.md"),
    ]
    
    # 2. Key Modules (manual selection or heuristic)
    key_modules = [
        ("Cloud Foundations (AWS)", "01-beginner/01-phase-1/07-cloud-foundations/05-aws-basics/readme.md"),
        ("Infrastructure as Code (Terraform)", "02-intermediate/02-phase-2/01-infrastructure-automation/02-config-management/02-iac-foundations-and-terraform/01-fundamentals/02-what-is-terraform.md"),
        ("Container Orchestration (Kubernetes)", "02-intermediate/03-phase-3/01-container-orchestration/readme.md"),
        ("Observability & Monitoring", "01-beginner/02-phase-2/07-observability-fundamentals/readme.md"),
        ("Career Mastery", "08-career-mastery/readme.md"),
    ]

    # 3. Generate Searchable Index (All .md files except reference and directory-map)
    all_md = []
    for dirpath, dirnames, filenames in os.walk(root):
        if any(part.startswith('.') for part in Path(dirpath).parts):
            continue
        for f in filenames:
            if f.endswith('.md') and f not in ['reference.md', 'directory-map.md', 'readme.md']:
                full_path = os.path.join(dirpath, f)
                rel_path = os.path.relpath(full_path, root)
                tier = rel_path.split('/')[0]
                name = Path(f).stem.replace('-', ' ').title()
                all_md.append((name, tier, rel_path))
    
    all_md.sort()

    content = []
    content.append("# 🚀 Root REFERENCE: The DevOps Master Logic")
    content.append("> **Unified Curriculum Entry Point | Senior Systems Architecture**\n")
    content.append("This file serves as the core entry point for the high-level logic across all tiers. Use this to quickly navigate frequent commands, architecture patterns, and the curriculum hierarchy.\n")
    content.append("---")
    content.append("## 🗺️ Navigation Index")
    content.append("\n".join([f"- **[{title}]({path})**" for title, path in nav]))
    content.append("\n---\n")
    
    content.append("## 🛠️ The DevOps Toolbelt (Quick Reference)")
    content.append("| Tool | Action | Command |")
    content.append("| :--- | :--- | :--- |")
    content.append("| **Git** | Automation | `python3 git-command.py --watch` |")
    content.append("| **Terraform** | IaC Lifecycle | `terraform plan / apply` |")
    content.append("| **Docker** | Containers | `docker build / run / exec` |")
    content.append("| **K8s** | Orchestration | `kubectl get pods -A` |")
    content.append("| **Python** | Logic | `python3 script-name.py` |")
    content.append("\n---\n")
    
    content.append("## 📚 Core Learning Pillars")
    content.append("\n".join([f"- [{title}]({path})" for title, path in key_modules]))
    content.append("\n---\n")

    content.append("## 🔍 Universal Search Index")
    content.append("<details>")
    content.append(f"<summary>Click to expand full file index ({len(all_md)} items)</summary>\n")
    content.append("| Resource | Tier | Path |")
    content.append("| :--- | :--- | :--- |")
    for name, tier, path in all_md:
        content.append(f"| {name} | {tier} | [{path}]({path}) |")
    content.append("\n</details>\n")
    
    content.append("\n---\n")
    content.append("*Last Updated: 2026-02-06 - Automated via Refactor Agent*")

    with open(os.path.join(root, "reference.md"), "w") as f:
        f.write("\n".join(content))

if __name__ == "__main__":
    generate_reference()
    print("✅ Reference.md updated.")
