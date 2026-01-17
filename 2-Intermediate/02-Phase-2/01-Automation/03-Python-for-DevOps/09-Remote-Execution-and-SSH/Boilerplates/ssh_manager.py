#!/usr/bin/env python3
"""
Name: ssh_manager.py
Description: Safe remote execution using Paramiko.
Requires: pip install paramiko
"""

import paramiko
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("ssh_ops")

def execute_remote(hostname, username, key_file, command):
    """
    Connects to a remote server and runs a command.
    """
    client = paramiko.SSHClient()
    
    # Policy to auto-add unknown host keys (Safe for internal dev, check for prod)
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        logger.info(f"Connecting to {hostname}...")
        client.connect(hostname, username=username, key_filename=key_file, timeout=10)
        
        logger.info(f"Executing: {command}")
        stdin, stdout, stderr = client.exec_command(command)
        
        # Read output
        out = stdout.read().decode().strip()
        err = stderr.read().decode().strip()
        exit_code = stdout.channel.recv_exit_status()
        
        if exit_code == 0:
            logger.info(f"Success:\n{out}")
            return True
        else:
            logger.error(f"Failed (Code {exit_code}):\n{err}")
            return False
            
    except Exception as e:
        logger.error(f"Connection Failed: {e}")
        return False
    finally:
        client.close()

if __name__ == "__main__":
    # Mock usage
    # execute_remote("192.168.1.10", "ubuntu", "/home/user/.ssh/id_rsa", "uptime")
    logger.info("This is a boilerplate. Configure IP/Key to run.")
