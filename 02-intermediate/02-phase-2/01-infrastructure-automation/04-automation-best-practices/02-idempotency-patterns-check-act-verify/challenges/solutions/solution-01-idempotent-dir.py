"""
Solution: Idempotent Directory Manager
"""
import os

def ensure_directory(path):
    if os.path.exists(path):
        if os.path.isdir(path):
            print(f"SKIP: Directory {path} already exists.")
            return True
        else:
            print(f"ERROR: {path} exists but is a file!")
            return False
            
    try:
        os.makedirs(path, exist_ok=True)
        if os.path.isdir(path):
            print(f"SUCCESS: Created {path}.")
            return True
    except Exception as e:
        print(f"FAILURE: Could not create {path}. Error: {e}")
        
    return False

if __name__ == "__main__":
    pass
