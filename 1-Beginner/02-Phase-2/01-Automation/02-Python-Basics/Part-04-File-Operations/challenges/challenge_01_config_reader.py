"""
Challenge: Config File Reader
Scenario: Create a function to read and parse key=value configuration files.

TODO: Implement `parse_config(filepath)` function:
1. Handle comments (lines starting with #)
2. Handle empty lines
3. Return a dictionary of settings
4. Perform basic type conversion (int, bool)
"""

# Test content (you can write this to a file first)
sample_config_content = """
# Database settings
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp

# App settings
DEBUG=true
LOG_LEVEL=INFO
"""

def parse_config(filepath):
    """Parse key=value config file into dictionary."""
    # --- START YOUR CODE HERE ---
    pass

# Test your code
if __name__ == "__main__":
    # Create a dummy config file
    with open("app.conf", "w") as f:
        f.write(sample_config_content)
    
    config = parse_config("app.conf")
    print("Parsed Config:", config)
