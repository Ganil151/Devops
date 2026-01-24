"""
Challenge: Duplicate File Finder
Scenario: Your storage server is running out of space. You need to identify 
duplicate files in a directory by comparing their MD5 hashes.

TODO: Implement `find_duplicates(directory)`.
1. Recursively iterate through all files in `directory` using `pathlib`.
2. For each file, calculate its MD5 hash.
3. Use a dictionary to keep track of hashes and their corresponding file paths.
4. Return a list of lists, where each sublist contains paths to identical files.
"""
import hashlib
from pathlib import Path

def get_file_hash(file_path):
    """Calculates the MD5 hash of a file."""
    # --- START YOUR CODE HERE ---
    pass

def find_duplicates(directory):
    """Finds duplicate files in a directory."""
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test your implementation on a temp directory
    test_dir = Path("test_files")
    test_dir.mkdir(exist_ok=True)
    (test_dir / "file1.txt").write_text("Hello World")
    (test_dir / "file2.txt").write_text("Hello World")
    (test_dir / "file3.txt").write_text("Unique Content")
    
    dupes = find_duplicates(test_dir)
    print(f"Duplicates: {dupes}")
