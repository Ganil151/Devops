#!/usr/bin/env python3
"""
Name: container_manager.py
Description: Interacting with Docker Engine API.
Requires: pip install docker
"""

import docker
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("docker_ops")

def list_containers():
    """Lists running containers."""
    try:
        # Connects to default socket (/var/run/docker.sock)
        client = docker.from_env()
        
        containers = client.containers.list()
        logger.info(f"Found {len(containers)} running containers:")
        for c in containers:
            logger.info(f"- {c.name} ({c.image.tags}) Status: {c.status}")
            
    except docker.errors.DockerException as e:
        logger.error(f"Docker Error: {e}")

def run_ephemeral_container(image="alpine", command="echo Hello"):
    """Runs a container and removes it after execution."""
    try:
        client = docker.from_env()
        logger.info(f"Running {image}...")
        
        # detach=False -> waits for output
        # remove=True -> clean up
        output = client.containers.run(image, command, remove=True)
        logger.info(f"Output: {output.decode().strip()}")
        
    except Exception as e:
        logger.error(f"Run Failed: {e}")

if __name__ == "__main__":
    # Check if we have access
    list_containers()
    # run_ephemeral_container()
