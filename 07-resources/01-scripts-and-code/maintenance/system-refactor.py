import os
import re
from pathlib import Path

def standardize(name, is_dir=False):
    # For files, preserve the extension
    if not is_dir:
        stem = Path(name).stem
        ext = Path(name).suffix
    else:
        stem = name
        ext = ""

    # 1. Replace & with 'and'
    new_stem = stem.replace('&', 'and')
    # 2. Replace spaces, underscores with hyphens
    new_stem = re.sub(r'[\s_]+', '-', new_stem)
    # 3. Remove non-alphanumeric (except hyphens)
    new_stem = re.sub(r'[^\w\-]', '', new_stem)
    # 4. Lowercase
    new_stem = new_stem.lower()
    # 5. Collapse multiple hyphens
    new_stem = re.sub(r'-+', '-', new_stem)
    # 6. Strip leading/trailing hyphens
    new_stem = new_stem.strip('-')

    return new_stem + ext.lower()

def execute_refactor(root_path):
    print(f"🚀 Starting DevOps Standard Refactor in: {root_path}")
    
    # We use topdown=False so we rename children before parents
    for dirpath, dirnames, filenames in os.walk(root_path, topdown=False):
        # Skip hidden directories like .git
        if any(part.startswith('.') for part in Path(dirpath).parts):
            continue

        # Rename Files
        for f in filenames:
            if f.startswith('.') or f == 'system_refactor.py':
                continue
            
            old_f_path = os.path.join(dirpath, f)
            new_f_name = standardize(f, is_dir=False)
            new_f_path = os.path.join(dirpath, new_f_name)
            
            if old_f_path != new_f_path:
                if not os.path.exists(new_f_path):
                    os.rename(old_f_path, new_f_path)
                    # print(f"  [FILE] {f} -> {new_f_name}")
                else:
                    print(f"  [SKIP] Conflict: {new_f_path} already exists")

        # Rename Directories
        for d in dirnames:
            if d.startswith('.'):
                continue
            
            old_d_path = os.path.join(dirpath, d)
            new_d_name = standardize(d, is_dir=True)
            new_d_path = os.path.join(dirpath, new_d_name)
            
            if old_d_path != new_d_path:
                if not os.path.exists(new_d_path):
                    os.rename(old_d_path, new_d_path)
                    # print(f"  [DIR]  {d} -> {new_d_name}")
                else:
                    print(f"  [SKIP] Conflict: {new_d_path} already exists")

if __name__ == "__main__":
    target = "/home/gsmash/Documents/Devops"
    execute_refactor(target)
    print("\n✅ Refactor Complete.")
