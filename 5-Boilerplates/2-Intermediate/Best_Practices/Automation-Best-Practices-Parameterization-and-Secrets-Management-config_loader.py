#!/usr/bin/env python3
"""
Name: config_loader.py
Description: Demonstrates safe parameter loading with environment variables.
"""

import os
import sys

# Define configuration with defaults
# This allows the script to run locally without setup, 
# but can be overridden in Production.
CONFIG = {
    "DB_HOST": os.getenv("APP_DB_HOST", "localhost"),
    "DB_PORT": int(os.getenv("APP_DB_PORT", 5432)),
    "LOG_LEVEL": os.getenv("APP_LOG_LEVEL", "INFO"),
    "API_KEY": os.getenv("APP_API_KEY") # No default for sensitive data
}

def validate_config():
    """Fail fast if critical secrets are missing."""
    if not CONFIG["API_KEY"]:
        print("CRITICAL ERROR: 'APP_API_KEY' environment variable not set.")
        print("Try: export APP_API_KEY=your_token_here")
        sys.exit(1)
    
    print(f"Config loaded: Host={CONFIG['DB_HOST']}, Port={CONFIG['DB_PORT']}")

def do_work():
    # Use the config
    print(f"Connecting to {CONFIG['DB_HOST']}...")
    # Masking secrets in output
    masked_key = CONFIG['API_KEY'][:4] + "****"
    print(f"Using API Key: {masked_key}")

if __name__ == "__main__":
    # Test by running: 
    # APP_API_KEY=123-abc python3 config_loader.py
    validate_config()
    do_work()
