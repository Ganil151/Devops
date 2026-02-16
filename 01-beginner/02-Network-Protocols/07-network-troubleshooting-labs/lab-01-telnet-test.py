import socket
import sys

def check_port(host, port, timeout=5):
    """
    SRE Pattern: Verifies if a remote port is reachable (Layer 4 check).
    Uses a strict timeout to prevent automation hangs.
    """
    try:
        # Create a socket object
        # AF_INET = IPv4, SOCK_STREAM = TCP
        with socket.create_connection((host, port), timeout=timeout) as sock:
            print(f"✅ Success: {host}:{port} is OPEN.")
            return True
    except socket.timeout:
        print(f"❌ Timeout: Connection to {host}:{port} timed out after {timeout}s.")
        return False
    except ConnectionRefusedError:
        print(f"❌ Refused: {host}:{port} is actively refusing connections (Service likely down).")
        return False
    except Exception as e:
        print(f"❌ Error: Could not connect to {host}:{port} - {e}")
        return False

if __name__ == "__main__":
    # Default to checking Google's HTTPS port if no args provided
    target_host = sys.argv[1] if len(sys.argv) > 1 else "8.8.8.8"
    target_port = int(sys.argv[2]) if len(sys.argv) > 2 else 443
    
    check_port(target_host, target_port)
