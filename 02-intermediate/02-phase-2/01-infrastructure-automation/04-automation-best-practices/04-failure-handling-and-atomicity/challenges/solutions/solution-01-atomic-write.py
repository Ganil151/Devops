"""
Solution: Atomic File Updater
"""
import os

def atomic_write(filename, content):
    temp_file = f"{filename}.tmp"
    try:
        # Write to temp
        with open(temp_file, "w") as f:
            f.write(content)
            
        # Atomic switch
        os.replace(temp_file, filename)
        print(f"SUCCESS: Atomic update of {filename} complete.")
        return True
        
    except Exception as e:
        print(f"FAILURE: Atomic write failed: {e}")
        if os.path.exists(temp_file):
            os.remove(temp_file)
            print("CLEANUP: Removed temp file.")
        return False

if __name__ == "__main__":
    pass
