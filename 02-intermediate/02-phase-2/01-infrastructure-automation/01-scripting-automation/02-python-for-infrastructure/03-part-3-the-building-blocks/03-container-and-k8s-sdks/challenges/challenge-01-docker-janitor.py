"""
Challenge: Docker Container Janitor
Scenario: Your build server is running out of disk space because of 
stopped containers. You need a script to clean them up automatically.

TODO: Implement `cleanup_stopped_containers()`.
1. Use `docker.from_env()` to get a client.
2. List all containers with `all=True`.
3. Check the status of each container.
4. If status is "exited", remove the container.
5. Print the names of the containers removed and return the total count.
"""
import docker

def cleanup_stopped_containers():
    """
    Finds and removes all exited Docker containers.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    count = cleanup_stopped_containers()
    print(f"Janitor finished. Removed {count} containers.")
