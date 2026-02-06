import os
import re

def to_kebab_case(name):
    # Replace & with 'and'
    name = name.replace('&', 'and')
    # Replace spaces and underscores with hyphens
    name = re.sub(r'[\s_]+', '-', name)
    # Remove dots and special characters except hyphens and alphanumeric
    name = re.sub(r'[^\w\-]', '', name)
    # Lowercase
    name = name.lower()
    # Remove duplicate hyphens
    name = re.sub(r'-+', '-', name)
    # Strip leading/trailing hyphens
    name = name.strip('-')
    return name

def refactor_name(name):
    # Check if it already has a 00- prefix
    if re.match(r'^\d{2}-', name):
        prefix = name[:3]
        rest = name[3:]
        return prefix + to_kebab_case(rest)
    else:
        # If it doesn't have a prefix, we might want to add one if it's a "primary module"
        # but for this audit, we focus on fixing the existing name
        return to_kebab_case(name)

# Root path
root = "/home/gsmash/Documents/Devops/"

audit_log = []

for dirpath, dirnames, filenames in os.walk(root):
    if '.git' in dirpath:
        continue
    
    for name in dirnames:
        old_path = os.path.join(dirpath, name)
        new_name = refactor_name(name)
        if new_name != name:
            audit_log.append({
                "type": "directory",
                "old": name,
                "new": new_name,
                "rel_path": os.path.relpath(dirpath, root)
            })

    for name in filenames:
        if name == ".DS_Store" or name.startswith('.'):
            continue
        new_name = refactor_name(name)
        # Handle extension better
        base, ext = os.path.splitext(name)
        new_base = refactor_name(base)
        new_name = new_base + ext.lower()
        
        if new_name != name:
            audit_log.append({
                "type": "file",
                "old": name,
                "new": new_name,
                "rel_path": os.path.relpath(dirpath, root)
            })

# Print first 20 for validation
for entry in audit_log[:20]:
    print(f"{entry['type'].capitalize()}: {entry['old']} -> {entry['new']} (at {entry['rel_path']})")

print(f"\nTotal violations found: {len(audit_log)}")
