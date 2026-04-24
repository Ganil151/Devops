"""
Solution: Duplicate File Finder
"""
import hashlib
from pathlib import Path
from collections import defaultdict

def get_file_hash(file_path):
    """Calculates hash in chunks to support large files."""
    hasher = hashlib.md5()
    with open(file_path, 'rb') as f:
        # Read in 4KB chunks
        for chunk in iter(lambda: f.read(4096), b""):
            hasher.update(chunk)
    return hasher.hexdigest()

def find_duplicates(directory):
    path = Path(directory)
    hashes = defaultdict(list)
    
    # rglob("*") iterates recursively
    for file_item in path.rglob("*"):
        if file_item.is_file():
            file_hash = get_file_hash(file_item)
            hashes[file_hash].append(str(file_item))
            
    # Return groups with more than 1 file
    return [paths for paths in hashes.values() if len(paths) > 1]

if __name__ == "__main__":
    # Test would run here
    pass
