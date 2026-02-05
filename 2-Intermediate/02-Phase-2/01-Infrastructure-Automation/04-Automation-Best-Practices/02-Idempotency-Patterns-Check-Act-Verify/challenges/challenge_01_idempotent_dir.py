"""
Challenge: Idempotent Directory Manager
Scenario: Your automation script creates a series of project folders. 
If the script fails halfway and is re-run, it should NOT try to create 
folders that already exist, and it should verify the final state.

TODO: Implement `ensure_directory(path)`.
1. Check if the directory already exists.
2. If it exists, print "SKIP: Directory {path} already exists" and return True.
3. If it doesn't exist, try to create it using `os.makedirs`.
4. After creation, verify it exists. If it does, print "SUCCESS: Created {path}".
5. Return True on success, False on failure.
"""
import os

def ensure_directory(path):
    """
    Ensures a directory exists (Idempotent).
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test your implementation
    test_path = "prod_logs/daily"
    
    print("--- First Run ---")
    ensure_directory(test_path)
    
    print("\n--- Second Run (Should Skip) ---")
    ensure_directory(test_path)
