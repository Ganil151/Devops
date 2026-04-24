"""
Solution: Server Health Checker
"""
import subprocess
import platform

def check_server(hostname):
    """Pings a server and returns status."""
    # Determine the count flag based on OS
    count_flag = "-n" if platform.system().lower() == "windows" else "-c"
    
    try:
        result = subprocess.run(
            ["ping", count_flag, "3", hostname],
            capture_output=True,
            text=True,
            timeout=10
        )
        
        return {
            "host": hostname,
            "reachable": result.returncode == 0,
            "output": result.stdout
        }
    except subprocess.TimeoutExpired:
        return {"host": hostname, "reachable": False, "error": "timeout"}
    except Exception as e:
        return {"host": hostname, "reachable": False, "error": str(e)}

if __name__ == "__main__":
    print(check_server("8.8.8.8"))
