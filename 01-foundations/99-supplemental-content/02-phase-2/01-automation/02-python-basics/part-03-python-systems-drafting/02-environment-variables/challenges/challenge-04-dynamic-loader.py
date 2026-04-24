"""
Challenge: Dynamic Environment Loader
Scenario: You want to load different configuration files based on the 'ENV' environment variable 
(e.g., development, staging, production).

TODO: Implement `setup_env()` function.
1. Determine the environment name from `os.environ.get("ENV")`. Default to "development".
2. Construct a filename: `.env.{environment}`.
3. Use `dotenv.load_dotenv(filename)` to load the specific file.
4. Print which file was loaded.
"""
import os
from dotenv import load_dotenv

def setup_env():
    """
    Loads appropriate .env file based on current ENV setting.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Create dummy files for testing
    with open(".env.development", "w") as f: f.write("DB_HOST=localhost\n")
    with open(".env.production", "w") as f: f.write("DB_HOST=db.prod.internal\n")
    
    # Test 1: Default (Dev)
    if "ENV" in os.environ: del os.environ["ENV"]
    setup_env()
    print("DB_HOST:", os.environ.get("DB_HOST"))
    
    # Test 2: Production
    os.environ["ENV"] = "production"
    setup_env()
    print("DB_HOST:", os.environ.get("DB_HOST"))
