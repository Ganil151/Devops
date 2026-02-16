"""
Environment Config Demo: Secure Application Loader
--------------------------------------------------
This script demonstrates the "12-Factor App" configuration pattern:
1. Safe loading with os.environ.get and defaults.
2. Strict validation for production environments.
3. Centralizing configuration into a type-safe Dataclass.
"""

import os
from dataclasses import dataclass
from typing import Optional

# 1. Architecture: Define a central configuration object
# Using a dataclass makes the config immutable and provides better IDE support.
@dataclass
class ServiceConfig:
    env_name: str
    port: int
    api_key: Optional[str]
    db_url: str
    debug_mode: bool

def load_system_config() -> ServiceConfig:
    """
    Factory function that builds our config from the OS environment.
    Demonstrates safe parsing and mandatory field enforcement.
    """
    # 1. Determine environment (defaults to development)
    current_env = os.environ.get("APP_ENV", "development").lower()
    
    # 2. Security Logic: Mandatory API Key in production
    key = os.environ.get("CLOUD_API_KEY")
    if current_env == "production" and not key:
        # Strict Failure: Prevent insecure production deployments
        raise EnvironmentError("❌ SECURITY CRITICAL: CLOUD_API_KEY must be set in production!")

    # 3. Type Casting Logic: Port must be an integer
    try:
        app_port = int(os.environ.get("SERVICE_PORT", 8080))
    except ValueError:
        print("[!] Warning: Invalid SERVICE_PORT format in environment. Defaulting to 8080.")
        app_port = 8080

    # 4. Return the structured object
    return ServiceConfig(
        env_name=current_env,
        port=app_port,
        api_key=key,
        db_url=os.environ.get("DATABASE_URL", "sqlite:///./dev.db"),
        debug_mode=os.environ.get("DEBUG_LOGS", "false").lower() == "true"
    )

def start_service(config: ServiceConfig):
    """Simple operational logic using the Config object."""
    print(f"\n--- Initializing {config.env_name.upper()} Service ---")
    print(f"Network: Listening on 0.0.0.0:{config.port}")
    print(f"Database: {config.db_url}")
    
    if config.api_key:
        print(f"Security: API Key detected (Length: {len(config.api_key)})")
    else:
        print("Security: No API Key (Local/Dev mode only)")
        
    if config.debug_mode:
        print("Logging: 🔥 VERBOSE/DEBUG MODE ACTIVE")

# --- Execution ---
if __name__ == "__main__":
    # Test 1: Simulating a default/dev setup
    print("[Test 1] Loading local/dev defaults...")
    dev_config = load_system_config()
    start_service(dev_config)

    # Test 2: Simulating a Production failure (Strict Mode Validation)
    print("\n[Test 2] Setting environment to PRODUCTION without an API Key...")
    os.environ["APP_ENV"] = "production"
    
    try:
        # This will raise an EnvironmentError
        load_system_config()
    except EnvironmentError as e:
        print(f"Caught Expected Safety Halt: {e}")
    
    # Test 3: Simulating a successful Production load
    print("\n[Test 3] Setting production variables successfully...")
    os.environ["CLOUD_API_KEY"] = "sk_live_51Mz..."
    prod_config = load_system_config()
    start_service(prod_config)
