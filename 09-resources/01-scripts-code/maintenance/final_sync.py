import os
import shutil
import re
from pathlib import Path

def standardize(name, is_dir=False):
    if not is_dir:
        stem = Path(name).stem
        ext = Path(name).suffix
    else:
        stem = name
        ext = ""
    num_match = re.match(r'^(\d+)([\s\.\-]+)', stem)
    prefix = ""
    if num_match:
        number = int(num_match.group(1))
        prefix = f"{number:02d}-"
        stem = stem[len(num_match.group(0)):]
    new_stem = stem.replace('&', 'and')
    new_stem = re.sub(r'[\s_]+', '-', new_stem)
    new_stem = re.sub(r'[^\w\-]', '', new_stem)
    new_stem = new_stem.lower()
    new_stem = re.sub(r'-+', '-', new_stem)
    new_stem = new_stem.strip('-')
    return (prefix + new_stem + ext.lower()).strip('-')

def final_refactor(root_path):
    root = Path(root_path)
    # Track actions for the log
    actions = []
    
    # Use topdown=False to rename contents before parents
    for dirpath, dirnames, filenames in os.walk(root, topdown=False):
        if any(part.startswith('.') for part in Path(dirpath).parts):
            continue

        # Files
        for f in filenames:
            if f.startswith('.') or f == 'git-command.py' or f == '00-REFACTOR-LOG.md':
                continue
            old_p = Path(dirpath) / f
            new_name = standardize(f, is_dir=False)
            new_p = Path(dirpath) / new_name
            if old_p != new_p:
                if not new_p.exists():
                    old_p.rename(new_p)
                else:
                    # Conflict: just delete the original if it's a dup or keep it
                    # Let's just move it with a suffix for safety if it's different
                    shutil.move(str(old_p), str(new_p) + ".dup")

        # Directories
        for d in dirnames:
            if d.startswith('.'):
                continue
            old_p = Path(dirpath) / d
            new_name = standardize(d, is_dir=True)
            new_p = Path(dirpath) / new_name
            if old_p != new_p:
                if not new_p.exists():
                    old_p.rename(new_p)
                else:
                    # Conflict (e.g. 09-Resources vs 09-resources)
                    # Merge contents and delete old
                    for item in old_p.iterdir():
                        target_item = new_p / item.name
                        if not target_item.exists():
                            shutil.move(str(item), str(target_item))
                        else:
                            # If target exists, move with suffix
                            shutil.move(str(item), str(target_item) + ".conflict")
                    old_p.rmdir()

if __name__ == "__main__":
    final_refactor("/home/gsmash/Documents/Devops")
    print("✅ Final Case Sync and Kebab-Case Enforced.")
