"""
Challenge: Bulk File Renamer
Scenario: You have a migration task. All `.txt` report files in a directory 
need to be renamed to have a `.log` extension, and we need to add a 
prefix of 'archive_' to each filename.

TODO: Implement `bulk_rename(directory, old_ext=".txt", new_ext=".log", prefix="archive_")`.
1. Iterate through all files in `directory` with the `old_ext`.
2. Construct the new filename (prefix + original_name_without_ext + new_ext).
3. Rename the file using `Path.rename()`.
4. Return a count of renamed files.
"""
from pathlib import Path

def bulk_rename(directory, old_ext=".txt", new_ext=".log", prefix="archive_"):
    """
    Renames multiple files in a directory.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test Setup
    test_dir = Path("rename_test")
    test_dir.mkdir(exist_ok=True)
    (test_dir / "report1.txt").touch()
    (test_dir / "report2.txt").touch()
    (test_dir / "notes.md").touch() # Should NOT be renamed
    
    count = bulk_rename(test_dir)
    print(f"Renamed {count} files.")
    # Verify:
    print(f"Files in directory: {[f.name for f in test_dir.iterdir()]}")
