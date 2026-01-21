"""
Solution: Log Rotation Script
"""
import os

def rotate_logs(log_file, keep_count=5):
    """Rotate log files, keeping last N versions."""
    
    # 1. Remove oldest backup if it exists
    oldest = f"{log_file}.{keep_count}"
    if os.path.exists(oldest):
        os.remove(oldest)
    
    # 2. Rotate existing backups (from keep_count-1 down to 1)
    for i in range(keep_count - 1, 0, -1):
        old_name = f"{log_file}.{i}"
        new_name = f"{log_file}.{i + 1}"
        if os.path.exists(old_name):
            os.rename(old_name, new_name)
    
    # 3. Rotate current to .1
    if os.path.exists(log_file):
        os.rename(log_file, f"{log_file}.1")
    
    # 4. Create new empty log file
    with open(log_file, "w") as f:
        pass  
    
    print(f"Rotated {log_file}, keeping {keep_count} backups")

if __name__ == "__main__":
    rotate_logs("myapp.log", keep_count=3)
