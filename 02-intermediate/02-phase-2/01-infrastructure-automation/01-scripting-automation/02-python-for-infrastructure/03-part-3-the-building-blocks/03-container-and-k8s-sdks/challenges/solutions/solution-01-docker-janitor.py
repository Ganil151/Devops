"""
Solution: Docker Container Janitor
"""
import docker

def cleanup_stopped_containers():
    client = docker.from_env()
    count = 0
    
    # List all containers (running and stopped)
    containers = client.containers.list(all=True)
    
    for container in containers:
        if container.status == "exited":
            print(f"Removing container: {container.name}")
            try:
                container.remove()
                count += 1
            except Exception as e:
                print(f"Failed to remove {container.name}: {e}")
                
    return count

if __name__ == "__main__":
    pass
