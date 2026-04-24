import os
import sys

def check_env():
    """Checks for critical environment variables."""
    required_vars = ["APP_ENV", "DB_HOST", "DB_PORT"]
    missing_vars = []

    print("--- Environment Health Check ---")
    for var in required_vars:
        value = os.getenv(var)
        if value:
            print(f"{var:10} : OK")
        else:
            print(f"{var:10} : MISSING")
            missing_vars.append(var)
    
    if missing_vars:
        print("\nERROR: Missing required environment variables.")
        sys.exit(1)
    else:
        print("\nSUCCESS: All critical variables are set.")
        sys.exit(0)

if __name__ == "__main__":
    check_env()
