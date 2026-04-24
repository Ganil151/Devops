"""
Challenge: Multi-Port Scanner
Scenario: Sometimes health isn't just one service. You need to verify that 
multiple ports (e.g., 80, 443, 22) are open on a single host.

TODO: Implement `scan_ports(host, ports)`.
1. Loop through the list of `ports`.
2. Use `socket.socket()` to attempt a connection to `(host, port)`.
3. Set a short timeout (e.g., 0.5 seconds).
4. Return a dictionary mapping ports to their status (Open/Closed).
"""
import socket

def scan_ports(host, ports):
    """
    Scans a host for multiple open ports.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    status = scan_ports("localhost", [22, 80, 443])
    print(f"Port Scan Status: {status}")
