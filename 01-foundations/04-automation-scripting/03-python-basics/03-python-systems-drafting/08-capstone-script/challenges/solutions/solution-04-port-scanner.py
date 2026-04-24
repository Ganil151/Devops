"""
Solution: Multi-Port Scanner
"""
import socket

def scan_ports(host, ports):
    """Checks multiple TCP ports for connectivity."""
    results = {}
    for port in ports:
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.settimeout(0.5)
                # connect_ex returns 0 on success (port open)
                if s.connect_ex((host, port)) == 0:
                    results[port] = "OPEN"
                else:
                    results[port] = "CLOSED"
        except Exception as e:
            results[port] = f"ERROR: {str(e)}"
    return results

if __name__ == "__main__":
    print(scan_ports("localhost", [22, 80]))
