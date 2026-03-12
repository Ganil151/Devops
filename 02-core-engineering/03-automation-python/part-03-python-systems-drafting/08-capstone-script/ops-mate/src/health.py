import subprocess
import requests
import logging
import platform

logger = logging.getLogger("ops-mate")

def check_http(url: str, timeout: int = 5) -> bool:
    """
    Checks if an HTTP URL returns a 200 OK status code.
    """
    try:
        response = requests.get(url, timeout=timeout)
        if response.status_code == 200:
            logger.debug(f"HTTP {url} -> 200 OK")
            return True
        else:
            logger.warning(f"HTTP {url} -> {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        logger.error(f"HTTP {url} -> ERROR: {e}")
        return False

def check_ping(ip: str) -> bool:
    """
    Pings an IP address. Uses cross-platform flags (-n for Windows, -c for Linux).
    """
    param = '-n' if platform.system().lower() == 'windows' else '-c'
    command = ['ping', param, '1', ip]
    
    try:
        # Redirect stdout/stderr to avoid cluttering the console
        result = subprocess.run(command, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if result.returncode == 0:
            logger.debug(f"PING {ip} -> SUCCESS")
            return True
        else:
            logger.warning(f"PING {ip} -> FAILED")
            return False
    except Exception as e:
        logger.error(f"PING {ip} -> EXCEPTION: {e}")
        return False
