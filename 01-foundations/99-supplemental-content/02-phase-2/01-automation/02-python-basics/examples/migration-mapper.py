import os
import shutil

base_dir = r"C:\Users\Ganil\Documents\Devops"
dest_dir = os.path.join(base_dir, "Boilerplate")
os.makedirs(dest_dir, exist_ok=True)

migration_map = []
commands = []

def clean_name(name):
    # Remove leading numbers and dots
    parts = name.split('-')
    if parts[0].isdigit():
        parts = parts[1:]
    name = "-".join(parts)
    # Simplify common names
    mapping = {
        "Shell-Scripting": "Shell",
        "Introduction": "Intro",
        "Python-Basics": "PythonBasics",
        "Python-for-DevOps": "PythonDevOps",
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
    if os.path.basename(root) in ["Boilerplate", "Boilerplates"]:
        if root == dest_dir: continue # Don't scan the destination itself
        if not files: continue
        
        # Determine prefix
        rel_path = os.path.relpath(root, base_dir)
        path_parts = rel_path.split(os.sep)
        
        # Attempt to find category and module
        # Example: 1-Beginner/02-Phase-2/01-Automation/01-Shell-Scripting/01-Introduction/Boilerplates
        # parts: ['1-Beginner', '02-Phase-2', '01-Automation', '01-Shell-Scripting', '01-Introduction', 'Boilerplates']
        
        category = "General"
        module = ""
        
        if len(path_parts) >= 4:
            category = clean_name(path_parts[3])
        if len(path_parts) >= 5:
            module = clean_name(path_parts[4])
        
        prefix = f"{category}"
        if module:
            prefix += f"-{module}"
            
        for file in files:
            source = os.path.join(root, file)
            new_filename = f"{prefix}-{file}"
            destination = os.path.join(dest_dir, new_filename)
            
            migration_map.append({
                "source": source,
                "dest": destination,
                "module_link": rel_path
            })
            
            # Escape spaces for shell
            src_cmd = f'"{source}"'
            dst_cmd = f'"{destination}"'
            commands.append(f"mv {src_cmd} {dst_cmd}")
            # Add location file command
            loc_file = os.path.join(root, "LOCATION.txt")
            loc_content = f"This boilerplate has been moved to /Devops/Boilerplate/{new_filename}"
            commands.append(f'echo "{loc_content}" > "{loc_file}"')

# Print Report
print("## MIGRATION MAP")
for item in migration_map:
    print(f"- {item['source']} -> {item['dest']}")

print("\n## BASH COMMANDS")
for cmd in commands:
    print(cmd)
