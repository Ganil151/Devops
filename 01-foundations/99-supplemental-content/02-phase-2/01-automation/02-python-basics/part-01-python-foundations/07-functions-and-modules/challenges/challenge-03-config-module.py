"""
Challenge: The 12-Factor Config Module
Scenario: Load configuration from Environment Variables securely.

TODO: Create a 'config/' package with the following files:
1. config/settings.py: A class defining defaults and REQUIRED_KEYS.
2. config/loader.py: A tool to read os.environ for vars starting with 'MYAPP_'.
3. config/__init__.py: The public API that loads and validates settings.

If you want to test in a single file first, implement the logic below.
"""
import os

# --- START YOUR CODE HERE ---

# 1. Define Settings class
# 2. Define load_from_env function
# 3. Implement validation logic

# --- END YOUR CODE HERE ---

if __name__ == "__main__":
    # Test with some mock env vars
    os.environ["MYAPP_API_KEY"] = "secret123"
    os.environ["MYAPP_DB_HOST"] = "localhost"
    
    # Your logic here to load and print config
    print("Config loaded successfully!")
