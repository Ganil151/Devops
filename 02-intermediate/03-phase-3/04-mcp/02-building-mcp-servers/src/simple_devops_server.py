from mcp.server.fastmcp import FastMCP
import psutil
import requests
import os
import subprocess
import json
from typing import Optional

# Initialize FastMCP - the name identifies the server in client interfaces
mcp = FastMCP("DevOps-Nexus")

@mcp.tool()
def get_system_metrics() -> str:
    """
    Retrieves real-time CPU, Memory, and Disk usage from the host machine.
    Use this to identify resource bottlenecks.
    """
    cpu = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory()
    disk = psutil.disk_usage('/')
    
    metrics = {
        "cpu_percent": cpu,
        "memory": {
            "total_gb": round(memory.total / (1024**3), 2),
            "available_gb": round(memory.available / (1024**3), 2),
            "percent_used": memory.percent
        },
        "disk": {
            "total_gb": round(disk.total / (1024**3), 2),
            "free_gb": round(disk.free / (1024**3), 2),
            "percent_used": disk.percent
        }
    }
    return json.dumps(metrics, indent=2)

@mcp.tool()
def check_http_health(url: str, timeout: int = 5) -> str:
    """
    Performs a detailed health check on an HTTP(S) endpoint.
    
    Args:
        url: The full URL to test (e.g., https://api.myapp.com/health)
        timeout: Seconds to wait before failing (default: 5)
    """
    try:
        response = requests.get(url, timeout=timeout)
        status = "HEALTHY" if response.status_code < 400 else "UNHEALTHY"
        return f"Status: {status} | Code: {response.status_code} | Latency: {response.elapsed.total_seconds():.3f}s"
    except Exception as e:
        return f"Status: CRITICAL | Error: {str(e)}"

@mcp.tool()
def list_docker_containers() -> str:
    """
    Lists running Docker containers and their status.
    Requires Docker to be installed and the user to have permissions.
    """
    try:
        result = subprocess.run(
            ["docker", "ps", "--format", "{{.Names}} ({{.Status}})"],
            capture_output=True, text=True, check=True
        )
        return result.stdout if result.stdout else "No containers running."
    except Exception as e:
        return f"Error accessing Docker: {str(e)}"

@mcp.resource("config://app-settings")
def get_app_config() -> str:
    """
    Provides access to the application configuration template.
    This is a static resource that the AI can read.
    """
    config_template = {
        "env": "production",
        "log_level": "INFO",
        "db_connection": "REDACTED",
        "features": {
            "autoscaling": True,
            "metrics_export": True
        }
    }
    return json.dumps(config_template, indent=2)

if __name__ == "__main__":
    mcp.run()
