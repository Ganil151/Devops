import os

boilerplate_dir = r"C:\Users\Ganil\Documents\Devops\Boilerplate"
base_dir = r"C:\Users\Ganil\Documents\Devops"
readme_path = os.path.join(boilerplate_dir, "README.md")
tiers = ["Beginner", "Intermediate", "Advanced"]

prefix_map = {
    "GoBasics": "1-Beginner/02-Phase-2/01-Automation/03-Go-Basics",
    "PythonBasics": "1-Beginner/02-Phase-2/01-Automation/02-Python-Basics",
    "Shell": "1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting",
    "Int-Shell": "2-Intermediate/02-Phase-2/01-Automation/01-Intermediate-Shell-Scripting",
    "Adv-Bash": "2-Intermediate/02-Phase-2/01-Automation/02-Advanced-Bash-Automation",
    "PythonDevOps": "2-Intermediate/02-Phase-2/01-Automation/03-Python-for-DevOps",
    "Ansible": "2-Intermediate/02-Phase-2/01-Automation/05-Ansible",
    "CICD": "2-Intermediate/02-Phase-2/03-CI-CD",
    "Jenkins": "2-Intermediate/02-Phase-2/03-CI-CD/02-Jenkins-Mastery",
    "TruffleHog": "2-Intermediate/02-Phase-2/03-CI-CD/03-Secret-Scanning-TruffleHog",
    "SonarQube": "2-Intermediate/02-Phase-2/03-CI-CD/04-Static-Code-Analysis-SonarQube",
    "Terraform": "2-Intermediate/02-Phase-2/02-Configuration-Tools/01-Terraform",
    "Chef": "2-Intermediate/02-Phase-2/02-Configuration-Tools/03-Chef",
    "Puppet": "2-Intermediate/02-Phase-2/02-Configuration-Tools/07-Puppet",
    "SaltStack": "2-Intermediate/02-Phase-2/02-Configuration-Tools/08-SaltStack",
    "Helm": "2-Intermediate/02-Phase-2/02-Configuration-Tools/04-Helm",
    "Kustomize": "2-Intermediate/02-Phase-2/02-Configuration-Tools/06-Kustomize",
    "Cloud-Init": "2-Intermediate/02-Phase-2/02-Configuration-Tools/05-Cloud-Init",
    "Packer": "2-Intermediate/02-Phase-2/02-Configuration-Tools/09-Packer",
    "Vagrant": "2-Intermediate/02-Phase-2/02-Configuration-Tools/10-Vagrant",
    "Pulumi": "2-Intermediate/02-Phase-2/02-Configuration-Tools/11-Pulumi",
    "Vendor-Tools": "2-Intermediate/02-Phase-2/02-Configuration-Tools/12-Vendor-Tools",
    "Infracost": "2-Intermediate/02-Phase-2/01-Automation/08-Infracost-Automation",
    "Automation-Best-Practices": "2-Intermediate/02-Phase-2/01-Automation/04-Automation-Best-Practices",
    "Real-Life-Scenarios": "2-Intermediate/02-Phase-2/01-Automation/07-Real-Life-Scenarios"
}

# Scan tiered directories
tier_files = {}
for t in tiers:
    t_path = os.path.join(boilerplate_dir, t)
    if os.path.exists(t_path):
        tier_files[t] = sorted(os.listdir(t_path))

new_readme = "# 🛠️ DevOps Central Boilerplate Repository\n\n"
new_readme += "This directory contains a centralized collection of all boilerplate code from across the DevOps curriculum, organized by skill level.\n\n"

for t in tiers:
    if t not in tier_files or not tier_files[t]: continue
    new_readme += f"## 📚 {t} Level\n\n"
    new_readme += "| Original File | Centralized File | Source Module |\n"
    new_readme += "| :--- | :--- | :--- |\n"
    
    for f in tier_files[t]:
        # Handle filename parts
        parts = f.split("-")
        orig_name = parts[-1]
        
        # Try to guess prefix and module name from filename
        # Prefixes can have dashes too (e.g. Adv-Bash)
        matched_prefix = ""
        for p in sorted(prefix_map.keys(), key=len, reverse=True):
            if f.startswith(p):
                matched_prefix = p
                break
        
        source_base = prefix_map.get(matched_prefix, "Unknown")
        
        # We can try to refine the source_base if we find a 'Boilerplates' folder
        # matching the middle parts of the filename.
        # Filename: [Prefix]-[Module]-[OrigName]
        if matched_prefix:
            # Module name is between prefix and orig_name
            module_candidate = f[len(matched_prefix)+1 : -len(orig_name)-1]
            # Since names were simplified/cleaned, we might not find an exact match easily.
            # But the user asked for organization, so a base module link is usually good enough.
            source_display = source_base.replace("\\", "/")
        else:
            source_display = "Unknown"
            
        new_readme += f"| {orig_name} | [`{f}`](./{t}/{f}) | [`{source_display}`](../{source_display}) |\n"
    new_readme += "\n"

with open(readme_path, "w", encoding="utf-8") as f:
    f.write(new_readme)

print("SUCCESS")
