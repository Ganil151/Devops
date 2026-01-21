"""
Challenge: Safe File Updater
Scenario: Safely update a JSON configuration file using atomic writes.

TODO: Implement `update_json_config(filepath, updates)` function:
1. Read existing JSON (or start empty if not found).
2. Update the dictionary with new values.
3. Write the updated data to a TEMPORARY file first.
4. Rename the temporary file to the original filepath (Atomic Write).
5. Handle potential errors (Invalid JSON, Permission Denied).
"""
import json
import os
import tempfile
import shutil

def update_json_config(filepath, updates):
    """Safely update JSON config file."""
    # --- START YOUR CODE HERE ---
    pass

# Test your code
if __name__ == "__main__":
    test_config = "settings.json"
    
    # 1. First update
    update_json_config(test_config, {"debug": True, "port": 8080})
    
    # 2. Second update (should merge)
    update_json_config(test_config, {"timeout": 30})
    
    with open(test_config, "r") as f:
        print("Final Config:", json.load(f))
