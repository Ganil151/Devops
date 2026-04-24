"""
Lab 2: Deployment Validator
---------------------------
Scenario: Before deploying a containerized app, you must validate that 
all required environment configuration is present.

Goal:
1. Use logical 'and' to verify multiple conditions.
2. Use 'if/else' to identify missing specific requirements.
"""

# --- Configuration (Simulating environment variables) ---
# Try changing these to empty strings "" or None to see the validator in action!
PORT = "8080"
DB_URL = "postgres://db.prod.company.com:5432"
TOKEN = ""  # Let's simulate a missing token

print("🏁 Starting Pre-flight Validation...")

# 1. Broad Validation using 'and'
if PORT and DB_URL and TOKEN:
    print("✅ All configuration detected.")
    print("🚀 Deploying application to the cluster...")

else:
    # 2. Granular error reporting
    print("❌ Validation Failed: Missing required configuration.")
    
    if not PORT:
        print("  - [ERROR] APP_PORT is not defined.")
    
    if not DB_URL:
        print("  - [ERROR] DATABASE_URL is not defined.")
        
    if not TOKEN:
        print("  - [ERROR] API_TOKEN is not defined.")

    # Practical DevOps tip: Exit with a non-zero code to stop a CI/CD pipeline
    # import sys; sys.exit(1)
