import os

def load_from_env(prefix="MYAPP"):
    """Reads all env vars starting with prefix"""
    data = {}
    for key, val in os.environ.items():
        if key.startswith(f"{prefix}_"):
            clean_key = key.replace(f"{prefix}_", "")
            data[clean_key] = val
    return data
