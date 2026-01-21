"""
Challenge: Mandatory Variable Validator
Scenario: Your automation script requires specific environment variables to be set 
(e.g., DB_URL, API_KEY) to function correctly in production.

TODO: Implement `validate_environment(required_vars)` function.
1. Check if each variable name in the 'required_vars' list exists in `os.environ`.
2. Collect all missing variables.
3. If any are missing, raise an `EnvironmentError` with a message listing them.
4. If all exist, print a success message.
"""
import os

REQUIRED_VARS = ["DB_URL", "API_KEY", "REGION"]

def validate_environment(required_vars):
    """
    Validates that all mandatory environment variables are present.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Simulate some environment vars
    os.environ["REGION"] = "us-east-1"
    
    try:
        validate_environment(REQUIRED_VARS)
    except EnvironmentError as e:
        print("Validation Failed:", e)
