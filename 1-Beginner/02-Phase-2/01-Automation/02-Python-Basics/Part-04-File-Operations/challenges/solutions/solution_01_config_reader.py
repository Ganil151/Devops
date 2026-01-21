"""
Solution: Config File Reader
"""

def parse_config(filepath):
    """Parse key=value config file into dictionary."""
    config = {}
    
    try:
        with open(filepath, "r") as f:
            for line in f:
                line = line.strip()
                
                # Skip empty lines and comments
                if not line or line.startswith("#"):
                    continue
                
                # Parse key=value
                if "=" in line:
                    key, value = line.split("=", 1)  # Split on first = only
                    key = key.strip()
                    value = value.strip()
                    
                    # Type conversion
                    if value.lower() == "true":
                        value = True
                    elif value.lower() == "false":
                        value = False
                    elif value.isdigit():
                        value = int(value)
                    
                    config[key] = value
    except FileNotFoundError:
        print(f"Error: {filepath} not found.")
    
    return config

# Test
if __name__ == "__main__":
    config = parse_config("app.conf")
    print(config)
