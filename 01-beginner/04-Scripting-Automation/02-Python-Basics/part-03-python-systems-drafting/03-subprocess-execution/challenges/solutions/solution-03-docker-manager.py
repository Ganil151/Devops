"""
Solution: Docker Container Manager
"""
import subprocess
import json

def list_running_containers():
    """List containers using docker ps --format json."""
    try:
        # Request JSON format from Docker CLI
        result = subprocess.run(
            ["docker", "ps", "--format", "{{json .}}"],
            capture_output=True,
            text=True,
            check=True
        )
        
        containers = []
        # docker ps outputs one JSON object per line
        for line in result.stdout.strip().split('\n'):
            if line:
                containers.append(json.loads(line))
        
        return containers
        
    except (subprocess.CalledProcessError, FileNotFoundError):
        # Docker not running or not installed
        return []

if __name__ == "__main__":
    containers = list_running_containers()
    for c in containers:
        print(f"Container: {c['Names']} | Image: {c['Image']}")
