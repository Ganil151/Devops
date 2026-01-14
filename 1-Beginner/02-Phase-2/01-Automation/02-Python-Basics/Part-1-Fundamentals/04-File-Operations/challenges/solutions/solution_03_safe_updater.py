"""
Solution: Safe File Updater
"""
import json
import os
import tempfile
import shutil

def update_json_config(filepath, updates):
    """Safely update JSON config file using atomic write."""
    
    # 1. Read existing config or start empty
    config = {}
    if os.path.exists(filepath):
        try:
            with open(filepath, "r") as f:
                config = json.load(f)
        except (json.JSONDecodeError, IOError) as e:
            print(f"Warning: Could not read {filepath} ({e}), starting fresh.")
    
    # 2. Apply updates
    config.update(updates)
    
    # 3. Write atomically
    dir_name = os.path.dirname(filepath) or "."
    try:
        # Create temp file in same directory
        with tempfile.NamedTemporaryFile(
            mode="w",
            dir=dir_name,
            suffix=".tmp",
            delete=False
        ) as tmp:
            json.dump(config, tmp, indent=2)
            tmp_path = tmp.name
        
        # 4. Atomic rename
        shutil.move(tmp_path, filepath)
        print(f"Successfully updated {filepath}")
    except Exception as e:
        print(f"Error updating config: {e}")
        if 'tmp_path' in locals() and os.path.exists(tmp_path):
            os.remove(tmp_path)
            
    return config

if __name__ == "__main__":
    update_json_config("settings.json", {"debug": True, "port": 8080})
    update_json_config("settings.json", {"timeout": 30})
