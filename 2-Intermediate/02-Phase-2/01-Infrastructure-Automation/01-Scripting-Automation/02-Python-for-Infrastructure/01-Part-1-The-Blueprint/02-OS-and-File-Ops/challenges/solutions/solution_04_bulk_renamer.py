"""
Solution: Bulk File Renamer
"""
from pathlib import Path

def bulk_rename(directory, old_ext=".txt", new_ext=".log", prefix="archive_"):
    path = Path(directory)
    count = 0
    
    # Iterate through files with old extension
    for file_path in path.glob(f"*{old_ext}"):
        if file_path.is_file():
            # Get original name without extension
            stem = file_path.stem
            # Create new name
            new_name = f"{prefix}{stem}{new_ext}"
            # Full path for new file
            new_path = file_path.with_name(new_name)
            
            # Rename
            file_path.rename(new_path)
            count += 1
            
    return count

if __name__ == "__main__":
    # Test logic
    pass
