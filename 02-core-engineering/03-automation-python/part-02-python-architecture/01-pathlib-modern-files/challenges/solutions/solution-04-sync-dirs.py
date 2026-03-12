"""
Solution: Directory Synchronizer
"""
from pathlib import Path
import shutil

def sync_dirs(source, destination):
    """Sync files from source to destination based on modification time."""
    src_root = Path(source)
    dst_root = Path(destination)
    
    if not src_root.exists():
        return
        
    for src_file in src_root.rglob("*"):
        if src_file.is_file():
            # Calculate where it should go
            rel_path = src_file.relative_to(src_root)
            dst_file = dst_root / rel_path
            
            # Decide if we need to copy
            should_copy = False
            if not dst_file.exists():
                should_copy = True
            elif src_file.stat().st_mtime > dst_file.stat().st_mtime:
                should_copy = True
                
            if should_copy:
                print(f"🔄 Syncing: {rel_path}")
                dst_file.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src_file, dst_file)

if __name__ == "__main__":
    # sync_dirs("src", "dst")
    pass
