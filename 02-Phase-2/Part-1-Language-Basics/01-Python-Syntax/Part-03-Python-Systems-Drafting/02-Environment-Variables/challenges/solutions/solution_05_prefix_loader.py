"""
Solution: Prefix-Based Config Loader
"""
import os

def get_app_config(prefix="APP_"):
    """Extracts all variables starting with a prefix and returns a clean dictionary."""
    app_config = {}
    for key, value in os.environ.items():
        if key.startswith(prefix):
            # Remove prefix and convert key to lowercase
            clean_key = key[len(prefix):].lower()
            app_config[clean_key] = value
    return app_config

if __name__ == "__main__":
    os.environ["APP_PORT"] = "8080"
    os.environ["APP_LOG_LEVEL"] = "DEBUG"
    print("App Config:", get_app_config())
