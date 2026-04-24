"""
Solution: Dynamic Environment Loader
"""
import os
from dotenv import load_dotenv

def setup_env():
    """Loads environment-specific .env files."""
    environment = os.environ.get("ENV", "development")
    env_file = f".env.{environment}"
    
    if os.path.exists(env_file):
        load_dotenv(env_file, override=True)
        print(f"✅ Loaded configuration from {env_file}")
    else:
        print(f"⚠️ Warning: {env_file} not found, proceeding with existing environment.")

if __name__ == "__main__":
    os.environ["ENV"] = "production"
    setup_env()
