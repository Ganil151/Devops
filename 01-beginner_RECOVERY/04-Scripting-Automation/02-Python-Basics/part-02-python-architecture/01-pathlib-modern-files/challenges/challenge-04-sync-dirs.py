"""
Challenge: Directory Synchronizer
Scenario: You need to sync a 'source' directory to a 'backup' location, 
but only copy files that are new or have been changed.

TODO: Implement `sync_dirs(source, destination)`.
1. Recursively find all files in `source`.
2. For each file, determine its relative path to `source`.
3. Check if the file exists in `destination`.
4. If it doesn't exist, or if the source file is newer (check `st_mtime`), 
   copy it to the matching relative path in `destination`.
5. Create any necessary subdirectories in `destination`.
"""
from pathlib import Path
import shutil

def sync_dirs(source, destination):
    """
    Syncs new or modified files from source to destination.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test stub
    # sync_dirs("code_dir", "nas_backup")
    pass
