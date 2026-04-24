import subprocess
import platform
from typing import Dict, Any

def check_ping(target: str) -> bool:
    """
    Performs a cross-platform ping check.
    """
    # Determine the flag based on the operating system
    param = "-n" if platform.system().lower() == "windows" else "-c"
    
    # Building the command list (safe pattern)
    command = ["ping", param, "1", target]
    
    try:
        # Run the command, suppress output for the checker logic
        subprocess.run(
            command, 
            stdout=subprocess.DEVNULL, 
            stderr=subprocess.DEVNULL, 
            check=True
        )
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False

def run_health_check(server: Dict[str, Any]) -> Dict[str, Any]:
    """
    Orchestrates the specific check type for a server.
    """
    server_name = server.get("name", "Unknown")
    target = server.get("target")
    check_type = server.get("type", "ping")
    
    result = {
        "name": server_name,
        "target": target,
        "type": check_type,
        "status": "DOWN"
    }
    
    if check_type == "ping":
        is_up = check_ping(target)
        result["status"] = "UP" if is_up else "DOWN"
        
    return result
