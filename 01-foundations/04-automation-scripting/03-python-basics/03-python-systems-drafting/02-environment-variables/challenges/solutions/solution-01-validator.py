"""
Solution: Mandatory Variable Validator
"""
import os

def validate_environment(required_vars):
    """Checks for missing environment variables and raises error if any found."""
    missing = [var for var in required_vars if var not in os.environ]
    
    if missing:
        raise EnvironmentError(f"Missing mandatory environment variables: {', '.join(missing)}")
    
    print("✅ All required environment variables are present.")

if __name__ == "__main__":
    REQUIRED_VARS = ["DB_URL", "API_KEY", "REGION"]
    
    # Test case: Missing variables
    try:
        validate_environment(REQUIRED_VARS)
    except EnvironmentError as e:
        print(f"Caught expected error: {e}")
