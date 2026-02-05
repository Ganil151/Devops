"""
Challenge: Atomic File Updater
Scenario: You are updating a critical component config file. If the 
script crashes while writing, the file might be corrupted. You must 
ensure the change is ATOMIC.

TODO: Implement `atomic_write(filename, content)`.
1. Create a temporary filename: `{filename}.tmp`.
2. Write the `content` to the temporary file.
3. Use `os.replace()` (or `os.rename`) to move the temp file to the 
   target `filename`. This is an atomic operation on most filesystems.
4. Add a `try...except` block to ensure that if anything fails, 
   the partial `.tmp` file is deleted.
"""
import os

def atomic_write(filename, content):
    """
    Writes content to a file atomically.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    target = "app_config.json"
    data = '{"status": "active", "version": "2.0"}'
    
    if atomic_write(target, data):
        print(f"Verified: {os.path.exists(target)}")
        with open(target) as f:
            print(f"Content: {f.read()}")
