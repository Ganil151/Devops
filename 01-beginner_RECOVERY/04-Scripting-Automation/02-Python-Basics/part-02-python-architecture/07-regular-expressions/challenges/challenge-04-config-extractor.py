"""
Challenge: Configuration Extractor
Scenario: You need to parse a simple configuration string that contains 
multiple `KEY=VALUE` pairs, ignoring comments (starting with `#`).

TODO: Implement `extract_config(config_text)`.
1. Use `re.finditer()` or `re.findall()`.
2. Construct a regex that:
   - Matches the start of a line.
   - Captures a word as the `KEY`.
   - Matches an `=` sign.
   - Captures everything until a `#` or the end of the line as the `VALUE`.
3. Trim whitespace from captured keys and values.
4. Return a dictionary of the config.
"""
import re

def extract_config(config_text):
    """
    Parses key-value pairs from a text configuration.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    config = """
    # Database Settings
    DB_HOST = 127.0.0.1
    DB_PORT = 5432  # default postgres port
    
    # API Settings
    API_KEY = abc-123-xyz
    """
    data = extract_config(config)
    print(f"Config Data: {data}")
