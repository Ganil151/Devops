"""
Challenge: Secure Secret Loader
Scenario: You are loading an API key from a local file. For security, 
your script must refuse to run if the file is 'world-readable' 
(meaning any user on the system can read it).

TODO: Implement `load_secure_secret(file_path)`.
1. Use `os.stat(file_path)` to check the file permissions.
2. In Linux/Mac terms, the permission should be restricted (e.g., 0o600).
3. On Windows, this is harder, so simulate it by checking if the owner 
   identity matches a specific condition (or just implement the logic 
   for Unix-like systems).
4. If permissions are too open, raise a `PermissionError`.
5. Otherwise, return the content of the file.
"""
import os
import stat

def load_secure_secret(file_path):
    """
    Loads a secret only if file permissions are restricted.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test script (Best run on a Unix-like environment or WSL)
    secret_file = "my_secret.key"
    with open(secret_file, "w") as f:
        f.write("SUPER_SECRET_TOKEN_123")
    
    try:
        # Note: on Windows, chmod doesn't behave the same way
        # This will mainly work on Linux/Mac
        if os.name != 'nt':
            os.chmod(secret_file, 0o644) # Too open
            print("Checking with open permissions (should fail)...")
            load_secure_secret(secret_file)
    except PermissionError as e:
        print(f"Success: Blocked insecure file! ({e})")
