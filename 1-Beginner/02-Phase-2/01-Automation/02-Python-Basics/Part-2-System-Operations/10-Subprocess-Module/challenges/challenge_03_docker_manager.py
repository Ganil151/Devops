"""
Challenge: Docker Container Manager
Scenario: You need a Python list of all running Docker containers to 
perform further automation (e.g., automated backups or restarts).

TODO: Implement `list_running_containers()`.
1. Run `docker ps --format "{{json .}}"`.
2. Capture the output.
3. Parse each line as a JSON object into a Python list.
4. Return the list.
"""
import subprocess
import json

def list_running_containers():
    """
    Returns a list of dictionaries representing running Docker containers.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    result = list_running_containers()
    if result:
        print(f"Found {len(result)} running containers.")
        for c in result:
            print(f"- {c.get('Names')} (Image: {c.get('Image')})")
    else:
        print("No running containers found or Docker is not available.")
