"""
Challenge: Remote Health Checker
Scenario: You need to check the disk space of a cluster. Instead of 
logging into each one, write a script to do it for you.

TODO: Implement `check_remote_disk(host, user, pkey_path)`.
1. Use Paramiko to connect via SSH using a private key (`RSAKey`).
2. Run the command `df -h / | tail -1 | awk '{print $5}'` to get 
   the usage percentage.
3. Return the percentage as an integer (e.g., 85).
4. Handle the `ssh.connect()` failure gracefully.
"""
import paramiko

def check_remote_disk(host, user, pkey_path):
    """
    Connects to a remote host and returns the root disk usage %.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Example usage (Dummy data)
    stats = check_remote_disk("10.0.0.1", "ubuntu", "~/.ssh/id_rsa")
    print(f"Disk Usage: {stats}%")
