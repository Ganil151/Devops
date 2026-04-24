"""
Error Handling Demo: Resilient Cloud Connectivity
------------------------------------------------
This script demonstrates:
1. EAFP (Easier to Ask Forgiveness than Permission) pattern.
2. Custom Exception types for business logic.
3. The `finally` block for guaranteed resource cleanup.
"""

import random
import time

# 1. Custom Exceptions (Modular & Descriptive)
class CloudServiceError(Exception):
    """Base exception for our cloud tools."""
    pass

class AuthFailure(CloudServiceError):
    """Specific error for credential issues."""
    pass

# 2. Resilient Function logic
def connect_to_cloud_api(retries: int = 3):
    """
    Simulates a flaky cloud connection with robust error handling.
    """
    print(f"Connecting to Cloud API (Max Retries: {retries})...")
    
    for attempt in range(1, retries + 1):
        try:
            # Simulate flaky network
            outcome = random.choice(["success", "timeout", "auth_fail", "error"])
            
            if outcome == "success":
                print("  [✓] Connection established.")
                return True
            elif outcome == "auth_fail":
                # Critical error, don't bother retrying
                raise AuthFailure("Invalid IAM Credentials for 'prod-deployer'")
            else:
                # Retryable network/service error
                print(f"  [!] Attempt {attempt} failed ({outcome})...")
                time.sleep(0.5)
                
        except AuthFailure as e:
            print(f"  [CRITICAL] Security Halt: {e}")
            raise # Re-raise to let the orchestrator handle it
        except Exception as e:
            # Catch-all for unexpected bugs
            print(f"  [FAILURE] Unexpected error: {e}")
            if attempt == retries:
                raise CloudServiceError("Connection exhausted.")

# 3. Orchestration with guaranteed cleanup
def run_deployment_pipeline():
    """
    Orchestrates the process and demonstrates 'finally'.
    """
    is_cloud_locked = True
    print("Locked Cloud Resource for Deployment.")
    
    try:
        connect_to_cloud_api()
        print("Deploying artifacts...")
    except CloudServiceError as e:
        print(f"Pipeline Aborted: {e}")
    finally:
        # This ALWAYS runs, preventing resource leaks
        is_cloud_locked = False
        print("UNLOCKED Cloud Resource (Guaranteed cleanup).")

# --- Execution ---
if __name__ == "__main__":
    run_deployment_pipeline()
