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

    # 1. Handle Numeric Prefixes (Enforce 0X- format)
    # Match strings like "1-", "2.", "3 " at the start
    num_match = re.match(r'^(\d+)([\s\.\-]+)', stem)
    prefix = ""
    if num_match:
        number = int(num_match.group(1))
        # Enforce two digits
        prefix = f"{number:02d}-"
        # Remove the original number and separator from the stem
        stem = stem[len(num_match.group(0)):]

    # 2. Replace & with 'and'
    new_stem = stem.replace('&', 'and')
    # 3. Replace spaces, underscores with hyphens
    new_stem = re.sub(r'[\s_]+', '-', new_stem)
    # 4. Remove non-alphanumeric (except hyphens)
    new_stem = re.sub(r'[^\w\-]', '', new_stem)
    # 5. Lowercase
    new_stem = new_stem.lower()
    # 6. Collapse multiple hyphens
    new_stem = re.sub(r'-+', '-', new_stem)
    # 7. Strip leading/trailing hyphens
    new_stem = new_stem.strip('-')

    final_name = prefix + new_stem + ext.lower()
    return final_name.strip('-')

def execute_refactor(root_path):
    print(f"🚀 Second Pass: Enforcing 2-Digit Prefixes and Deep Cleaning: {root_path}")
    
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
                    # If conflict exists, maybe append a random suffix or keep old for safety
                    # For this task, we will try to merge or handle gracefully
                    pass

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
                else:
                    # print(f"  [DIR CONFLICT]  {d} -> {new_d_name}")
                    pass

if __name__ == "__main__":
    target = "/home/gsmash/Documents/Devops"
    execute_refactor(target)
    print("\n✅ Second Pass Refactor Complete.")
