import os
import re
from pathlib import Path
import json

def standardize(name, is_dir=False):
    if not is_dir:
        stem = Path(name).stem
        ext = Path(name).suffix
    else:
        stem = name
        ext = ""

    # 1. Handle Numeric Prefixes (Enforce 0X- format)
    num_match = re.match(r'^(\d+)([\s\.\-]+)', stem)
    prefix = ""
    if num_match:
        number = int(num_match.group(1))
        prefix = f"{number:02d}-"
        stem = stem[len(num_match.group(0)):]

    # 2. Logic: Lowercase and replace special chars
    new_stem = stem.replace('&', 'and')
    new_stem = re.sub(r'[\s_]+', '-', new_stem)
    new_stem = re.sub(r'[^\w\-]', '', new_stem)
    new_stem = new_stem.lower()
    new_stem = re.sub(r'-+', '-', new_stem)
    new_stem = new_stem.strip('-')

    final_name = prefix + new_stem + ext.lower()
    return final_name.strip('-')

def dry_run_refactor(root_path):
    mapping = []
    root = Path(root_path)
    
    # We walk topdown=False to ensure we see children before parents for renaming logic,
    # but here we just collect data.
    for dirpath, dirnames, filenames in os.walk(root, topdown=False):
        # Skip hidden
        if any(part.startswith('.') for part in Path(dirpath).parts):
            continue
            
        rel_dir = os.path.relpath(dirpath, root)
        
        for name in dirnames + filenames:
            if name.startswith('.') or name == '00-REFACTOR-LOG.md' or name == 'git-command.py':
                continue
                
            is_dir = os.path.isdir(os.path.join(dirpath, name))
            new_name = standardize(name, is_dir=is_dir)
            
            if name != new_name:
                old_rel = os.path.join(rel_dir, name) if rel_dir != "." else name
                new_rel = os.path.join(rel_dir, new_name) if rel_dir != "." else new_name
                mapping.append({
                    "old": old_rel,
                    "new": new_rel,
                    "type": "Directory" if is_dir else "File"
                })
    
    return mapping

if __name__ == "__main__":
    target = "/home/gsmash/Documents/Devops"
    results = dry_run_refactor(target)
    
    # Generate 00-REFACTOR-LOG.md
    log_content = [
        "# 📑 DevOps Curriculum Refactor Log",
        f"**Date:** {os.popen('date').read().strip()}",
        "**Status:** DRY RUN / PROPOSED",
        "\n## 🗺️ Migration Mapping Table",
        "| Type | Old Path | New Standard Path |",
        "| :--- | :--- | :--- |"
    ]
    
    for item in sorted(results, key=lambda x: x['old']):
        log_content.append(f"| {item['type']} | `{item['old']}` | `{item['new']}` |")
    
    with open(os.path.join(target, "00-REFACTOR-LOG.md"), "w") as f:
        f.write("\n".join(log_content))
    
    print(f"✅ Dry Run Complete. {len(results)} changes identified.")
    print(f"📂 Refactor Log created: /home/gsmash/Documents/Devops/00-REFACTOR-LOG.md")
