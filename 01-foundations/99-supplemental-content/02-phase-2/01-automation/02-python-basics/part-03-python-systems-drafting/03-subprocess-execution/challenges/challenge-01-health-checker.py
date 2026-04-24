"""
Challenge: Server Health Checker
Scenario: You need a tool to check if a list of servers is reachable.

TODO: Implement `check_server(hostname)` function.
1. Run the `ping` command (3 times).
2. Use `subprocess.run` with a timeout of 10 seconds.
3. Capture the output to extract latency information (optional but recommended).
4. Return a dictionary with 'reachable' (True/False) and 'host'.
"""
import subprocess
import re

def check_server(hostname):
    """
    Pings a server and returns its reachability status.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    hosts = ["google.com", "8.8.8.8", "invalid.hostname.test"]
    
    for host in hosts:
        status = check_server(host)
        print(f"Host: {status['host']} | Reachable: {status['reachable']}")
