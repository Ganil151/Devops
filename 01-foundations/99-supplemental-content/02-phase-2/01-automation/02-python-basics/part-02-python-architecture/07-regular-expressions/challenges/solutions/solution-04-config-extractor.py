"""
Solution: Configuration Extractor
"""
import re

def extract_config(config_text):
    """Parse key=value pairs ignoring comments."""
    # Pattern explanation:
    # ^\s*          - Start of line index + optional whitespace
    # (?P<key>\w+)  - Named group 'key' for words
    # \s*=\s*       - Equals sign with optional whitespace
    # (?P<val>[^#\n]+) - Named group 'val' for everything not a comment or newline
    pattern = r'^\s*(?P<key>\w+)\s*=\s*(?P<val>[^#\n]+)'
    
    config = {}
    for match in re.finditer(pattern, config_text, re.MULTILINE):
        key = match.group('key').strip()
        val = match.group('val').strip()
        config[key] = val
        
    return config

if __name__ == "__main__":
    text = """
    PORT = 8080
    DEBUG = true # set to false in prod
    """
    print(extract_config(text))
