"""
Resource Monitor (Cross-Platform)
Description: Monitors CPU, Memory, and Disk usage using agnostic libraries.
Output: JSON formatted metrics.
"""

import sys
import json
import psutil
import platform
import logging
from datetime import datetime

# Setup Logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger(__name__)

def get_system_metrics():
    """Gathers system metrics in a dictionary."""
    try:
        # CPU
        cpu_percent = psutil.cpu_percent(interval=1)
        
        # Memory
        mem = psutil.virtual_memory()
        mem_usage = mem.percent
        
        # IO / Disk
        disk = psutil.disk_usage('/')
        disk_usage = disk.percent
        
        # Network
        net = psutil.net_io_counters()

        metrics = {
            "timestamp": datetime.utcnow().isoformat(),
            "os": platform.system(),
            "node": platform.node(),
            "cpu": {
                "usage_percent": cpu_percent,
                "count": psutil.cpu_count()
            },
            "memory": {
                "total_gb": round(mem.total / (1024**3), 2),
                "used_percent": mem_usage
            },
            "disk": {
                "path": "/",
                "used_percent": disk_usage
            },
            "network": {
                "bytes_sent": net.bytes_sent,
                "bytes_recv": net.bytes_recv
            }
        }
        return metrics

    except Exception as e:
        logger.error(f"Failed to gather metrics: {e}")
        return None

def main():
    logger.info("Starting Resource Monitor...")
    
    data = get_system_metrics()
    
    if data:
        print(json.dumps(data, indent=2))
        if data['cpu']['usage_percent'] > 90:
            logger.warning("High CPU Load detected!")
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()
