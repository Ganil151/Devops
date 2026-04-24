"""
Solution: Type-Safe Bool Parser
"""
import os

def get_env_bool(name, default=False):
    """Correctly handles various string representations of booleans."""
    if name not in os.environ:
        return default
        
    val = os.environ[name].lower()
    return val in ("true", "1", "t", "y", "yes", "on")

if __name__ == "__main__":
    os.environ["DEBUG"] = "true"
    print(f"DEBUG: {get_env_bool('DEBUG')}")
