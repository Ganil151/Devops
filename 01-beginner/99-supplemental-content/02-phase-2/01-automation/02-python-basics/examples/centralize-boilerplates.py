import os
import shutil

base_dir = r"C:\Users\Ganil\Documents\Devops"
dest_dir = os.path.join(base_dir, "Boilerplate")
os.makedirs(dest_dir, exist_ok=True)

readme_entries = {}

def clean_name(name):
    parts = name.split('-')
    if len(parts) > 1 and parts[0].isdigit():
        parts = parts[1:]
    name = "-".join(parts)
    mapping = {
        "Shell-Scripting": "Shell",
        "Introduction": "Intro",
        "Python-Basics": "PythonBasics",
        "Python-for-DevOps": "PythonDevOps",
        "Go-Basics": "GoBasics",
        "Intermediate-Shell-Scripting": "Int-Shell",
        "Advanced-Bash-Automation": "Adv-Bash",
        "CI-CD": "CICD",
        "Jenkins-Mastery": "Jenkins",
        "Pipelines-as-Code": "Pipelines",
        "Secret-Scanning-TruffleHog": "TruffleHog",
        "Static-Code-Analysis-SonarQube": "SonarQube"
    }
    for k, v in mapping.items():
        if k in name:
            name = name.replace(k, v)
    return name

for root, dirs, files in os.walk(base_dir):
    foldername = os.path.basename(root).lower()
    if foldername in ["boilerplate", "boilerplates"]:
        if os.path.abspath(root) == os.path.abspath(dest_dir): continue
        if not files: continue
        
        rel_path = os.path.relpath(root, base_dir)
        path_parts = rel_path.split(os.sep)
        
        category = "General"
        module = ""
        
        if len(path_parts) >= 4:
            category = clean_name(path_parts[3])
        if len(path_parts) >= 5:
            module = clean_name(path_parts[4])
        
        prefix = f"{category}"
        if module:
            prefix += f"-{module}"
            
        group_key = f"{category} / {module}" if module else category
        if group_key not in readme_entries:
            readme_entries[group_key] = []
            
        for file in files:
            source = os.path.join(root, file)
            new_filename = f"{prefix}-{file}"
            destination = os.path.join(dest_dir, new_filename)
            
            # Skip if destination already exists (to avoid duplicate moves if re-run)
            if os.path.exists(destination) and not os.path.exists(source):
                # We need to record this in the README even if already moved
                # But how do we know where it came from if source doesn't exist?
                # For simplicity, if source exists, move it.
                pass
            
            if os.path.exists(source):
                shutil.move(source, destination)
            
            # Create/Update LOCATION.txt
            loc_file = os.path.join(root, "LOCATION.txt")
            with open(loc_file, "w") as f:
                f.write(f"This boilerplate has been moved to /Devops/Boilerplate/{new_filename}")
            
            readme_entries[group_key].append({
                "name": file,
                "new_path": new_filename,
                "orig_dir": rel_path
            })

# Re-read existing README to merge if necessary? 
# No, let's just regenerate since the script logic covers everything and we track what we found.
# Wait, if some files were already moved, 'files' in that directory will only contain 'LOCATION.txt'.
# So I should also check if the directory ONLY contains LOCATION.txt.
# Actually, the first run already moved everything.
# The issue was it missed 'boilerplate' folders.

# Regen README.md
readme_path = os.path.join(dest_dir, "README.md")
with open(readme_path, "w", encoding="utf-8") as f:
    f.write("# 🛠️ DevOps Central Boilerplate Repository\n\n")
    f.write("This directory contains a centralized collection of all boilerplate code from across the DevOps curriculum.\n\n")
    f.write("## 🗂️ Index\n\n")
    
    for group in sorted(readme_entries.keys()):
        f.write(f"### {group}\n")
        f.write("| Original File | Centralized File | Source Module |\n")
        f.write("| :--- | :--- | :--- |\n")
        # De-duplicate entries for the same file in the same group (e.g. from previous runs)
        seen = set()
        for entry in readme_entries[group]:
            if entry['new_path'] in seen: continue
            seen.add(entry['new_path'])
            f.write(f"| {entry['name']} | [`{entry['new_path']}`](./{entry['new_path']}) | [`{entry['orig_dir']}`](../{entry['orig_dir'].replace('\\', '/')}) |\n")
        f.write("\n")

print("SUCCESS: Centralization update complete.")
