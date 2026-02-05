"""
Solution: Secure Secret Loader
"""
import os
import stat

def load_secure_secret(file_path):
    """Refuses to read if permissions are too broad (Linux/Unix)."""
    if os.name != 'nt': # Unix checking
        file_stat = os.stat(file_path)
        # Check 'group readable' and 'world readable' bits
        # S_IRGRP: group read, S_IROTH: others read
        if (file_stat.st_mode & stat.S_IRGRP) or (file_stat.st_mode & stat.S_IROTH):
            raise PermissionError(f"Security Risk: {file_path} is readable by others!")
            
    with open(file_path, 'r') as f:
        return f.read().strip()

if __name__ == "__main__":
    # Example logic
    pass
