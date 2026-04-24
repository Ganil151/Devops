from mcp.server.fastmcp import FastMCP
import os
import re

# Initialize FastMCP
mcp = FastMCP("The-Guardian")

# Configuration: Scoped base directory for file operations
SAFE_DIR = os.path.abspath("./sandbox")

# Ensure the sandbox exists for the demo
os.makedirs(SAFE_DIR, exist_ok=True)

def is_safe_path(path: str) -> bool:
    """Checks if the path is contained within the SAFE_DIR."""
    abs_path = os.path.abspath(os.path.join(SAFE_DIR, path))
    return abs_path.startswith(SAFE_DIR)

@mcp.tool()
def read_project_file(filename: str) -> str:
    """
    Safely reads a file from the project sandbox.
    Prevents directory traversal attacks.
    """
    if not is_safe_path(filename):
        return "Error: SECURITY_VIOLATION. Attempted to read outside sandbox."
    
    target = os.path.join(SAFE_DIR, filename)
    if not os.path.exists(target):
        return f"Error: File '{filename}' not found."
    
    try:
        with open(target, 'r') as f:
            return f.read()
    except Exception as e:
        return f"Error reading file: {str(e)}"

@mcp.tool()
def deploy_to_environment(env: str, service_name: str) -> str:
    """
    Simulates a deployment with strict environment validation.
    
    Args:
        env: Target environment (must be 'staging' or 'prod')
        service_name: Name of the service to deploy
    """
    # Strict Input Validation
    allowed_envs = ["staging", "prod"]
    if env not in allowed_envs:
        return f"Error: Invalid environment '{env}'. Must be one of {allowed_envs}."
    
    # Regex validation for service names (alphanumeric only)
    if not re.match(r"^[a-z0-9-]+$", service_name):
        return "Error: Invalid service name format. Use lowercase alphanumeric and hyphens."

    # Human-in-the-loop (HITL) Simulation
    if env == "prod":
        return f"CRITICAL: Deployment of '{service_name}' to PROD requested. Please confirm in Host UI."
    
    return f"Success: Deployed '{service_name}' to {env}."

if __name__ == "__main__":
    mcp.run()
