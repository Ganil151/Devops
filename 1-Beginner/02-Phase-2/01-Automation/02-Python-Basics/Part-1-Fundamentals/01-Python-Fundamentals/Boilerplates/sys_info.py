#!/usr/bin/env python3
"""
Boilerplate: System Information Gatherer
DevOps Context: Pre-flight checks and environment validation.
"""
import sys
import platform
import os
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def check_python_version():
    """Verify Python version meets requirements."""
    required = (3, 6)
    current = sys.version_info
    
    logger.info(f"Python Implementation: {platform.python_implementation()}")
    logger.info(f"Python Version: {sys.version}")
    
    if current < required:
        logger.error(f"Python {required[0]}.{required[1]}+ required, found {current.major}.{current.minor}")
        return False
    return True

def get_system_info():
    """Gather basic system metrics (simulated)."""
    info = {
        "os": platform.system(),
        "release": platform.release(),
        "architecture": platform.machine(),
        "processor": platform.processor(),
        "cpu_count": os.cpu_count()
    }
    return info

def main():
    logger.info("Starting Pre-flight System Check...")
    
    if not check_python_version():
        sys.exit(1)
        
    sys_info = get_system_info()
    logger.info("System Configuration:")
    for key, value in sys_info.items():
        print(f"  {key.title()}: {value}")
        
    # Example DevOps Logic: Check for Linux
    if sys_info['os'] != "Linux":
        logger.warning("Not running on Linux. Some DevOps tools might behave differently.")
    else:
        logger.info("Environment matches production (Linux).")

if __name__ == "__main__":
    main()
