import psutil
import asyncio
import logging

# Configuration
TEMP_THRESHOLD_WARN = 75.0  # Celsius - Start slowing down
TEMP_THRESHOLD_CRITICAL = 85.0  # Celsius - Pause all requests
CHECK_INTERVAL = 2.0  # Seconds between checks

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("ThermalGuard")

def get_cpu_temp():
    """Reads the current CPU temperature."""
    temps = psutil.sensors_temperatures()
    if 'coretemp' in temps:
        # Returns the average of all cores
        core_temps = [entry.current for entry in temps['coretemp']]
        return sum(core_temps) / len(core_temps)
    elif 'cpu_thermal' in temps:
        return temps['cpu_thermal'][0].current
    return 50.0  # Fallback if sensors aren't detected

async def throttle_logic():
    """Returns a delay time (seconds) based on heat."""
    current_temp = get_cpu_temp()
    
    if current_temp >= TEMP_THRESHOLD_CRITICAL:
        logger.warning(f"CRITICAL TEMP: {current_temp}°C. Pausing for 10s.")
        return 10.0
    elif current_temp >= TEMP_THRESHOLD_WARN:
        delay = (current_temp - TEMP_THRESHOLD_WARN) * 0.5
        logger.info(f"High Temp: {current_temp}°C. Throttling {delay:.2f}s.")
        return delay
    return 0.0
