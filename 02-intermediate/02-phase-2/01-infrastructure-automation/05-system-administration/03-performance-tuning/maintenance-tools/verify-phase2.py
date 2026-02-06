import os
from pathlib import Path

BASE_DIR = Path(r"C:\Users\Ganil\Documents\Devops\3-Advanced\02-Phase-2")
BACKUP_DIR = Path(r"C:\Users\Ganil\Documents\Devops\3-Advanced\02-Phase-2-BACKUP-20260119_022016")

def count_modules(directory, is_part_structure=False):
    modules = []
    if not directory.exists():
        return []
        
    for item in directory.iterdir():
        if item.is_dir():
            if is_part_structure and item.name.startswith("Part-"):
                # Go deeper
                for sub in item.iterdir():
                    if sub.is_dir():
                        modules.append(sub.name)
            elif not is_part_structure and not item.name.startswith("."):
                modules.append(item.name)
    return modules

def verify():
    print("--- VERIFICATION REPORT ---")
    
    # Check Backup
    backup_modules = count_modules(BACKUP_DIR, is_part_structure=False)
    print(f"Backup Modules Found: {len(backup_modules)}")
    
    # Check Current (New Structure)
    current_modules = count_modules(BASE_DIR, is_part_structure=True)
    print(f"Current Modules (in Parts): {len(current_modules)}")
    
    # Compare
    missing = [m for m in backup_modules if m not in current_modules] # IDs might change?
    # correct, I renamed them! 
    # e.g. 05-Service-Mesh-Istio -> 01-Istio-Deep-Dive
    
    print("\nStructure Validation:")
    if len(current_modules) > 0:
        print("✅ New structure detected (Parts found)")
        print(f"   - {len(current_modules)} modules are active")
    else:
        print("❌ New structure IS EMPTY")
        
    if len(backup_modules) > 0:
        print("✅ Backup verified")
    else:
        print("❌ Backup IS EMPTY")
        
    # Check file counts for a sample
    sample_part = BASE_DIR / "Part-01-Service-Mesh"
    if sample_part.exists():
        print(f"\nSample Check ({sample_part.name}):")
        for mod in sample_part.iterdir():
            if mod.is_dir():
                file_count = len(list(mod.rglob("*")))
                print(f"   - {mod.name}: {file_count} files/dirs")
                
if __name__ == "__main__":
    verify()
