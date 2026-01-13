DEFAULT_PORT = 22
DEFAULT_TIMEOUT = 30

def connect(hostname, port=DEFAULT_PORT):
    """Establish connection to server."""
    print(f"Connecting to {hostname}:{port}")
    return {"connected": True, "host": hostname}

def disconnect(connection):
    """Close server connection."""
    print(f"Disconnecting from {connection['host']}")
    

class ServerConnection:
    def __init__(self, hostname):
        self.hostname = hostname
        self.connected = False

    def connect(self):
        self.connected = True
