"""
Solution: Safe File Backup
"""
from pathlib import Path
import shutil
from datetime import datetime

def backup_config(config_file, backup_dir, max_backups=5):
    """Create a timestamped backup and enforce rotation."""
    src = Path(config_file)
    dst_dir = Path(backup_dir)
    
    if not src.exists():
        raise FileNotFoundError(f"Source file {src} not found")
        
    # Create backup directory
    dst_dir.mkdir(parents=True, exist_ok=True)
    
    # Generate timestamped name
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_name = f"{src.stem}_{ts}{src.suffix}"
    backup_file = dst_dir / backup_name
    
    # Copy file
    shutil.copy2(src, backup_file)
    
    # Rotate: Keep only the newest max_backups
    backups = sorted(
        dst_dir.glob(f"{src.stem}_*{src.suffix}"),
        key=lambda x: x.stat().st_mtime
    )
    
    while len(backups) > max_backups:
        oldest = backups.pop(0)
        print(f"🗑️ Rotating (deleting) oldest backup: {oldest.name}")
        oldest.unlink()
        
    return backup_file

if __name__ == "__main__":
    # backup_config("settings.json", "backups")
    pass
