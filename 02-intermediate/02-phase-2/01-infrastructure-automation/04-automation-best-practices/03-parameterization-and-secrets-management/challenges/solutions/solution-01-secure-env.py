"""
Solution: Secure Config Orchestrator
"""
import os

def get_secure_key(key_name, default=None):
    # 1. Try Environment
    val = os.getenv(key_name)
    if val:
        print(f"INFO: Loaded {key_name} from Environment.")
        return val
        
    # 2. Try .secrets file
    if os.path.exists(".secrets"):
        with open(".secrets", "r") as f:
            for line in f:
                if '=' in line:
                    k, v = line.strip().split('=', 1)
                    if k == key_name:
                        print(f"INFO: Loaded {key_name} from .secrets file.")
                        return v
                        
    # 3. Use default
    print(f"INFO: Using default value for {key_name}.")
    return default

if __name__ == "__main__":
    pass
