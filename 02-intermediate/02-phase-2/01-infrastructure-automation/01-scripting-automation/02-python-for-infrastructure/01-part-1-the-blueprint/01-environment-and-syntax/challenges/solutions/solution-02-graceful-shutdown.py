"""
Solution: Graceful Shutdown Handler
"""
import signal
import sys
import os
import time

def cleanup_handler(signum, frame):
    """Cleanup logic on signal."""
    print(f"\nCaught signal {signum}. Starting cleanup...")
    
    if os.path.exists("active_task.lock"):
        os.remove("active_task.lock")
        print("Removed active_task.lock")
        
    print("Cleanup complete. Exiting.")
    sys.exit(0)

if __name__ == "__main__":
    # Register handlers for both Ctrl+C and OS termination
    signal.signal(signal.SIGINT, cleanup_handler) # Ctrl+C
    # SIGTERM might not be available on Windows the same way, but it's good practice
    if hasattr(signal, 'SIGTERM'):
        signal.signal(signal.SIGTERM, cleanup_handler)

    # Create dummy file
    with open("active_task.lock", "w") as f:
        f.write("running")

    print("Worker is running. Press Ctrl+C to terminate gracefully.")
    while True:
        time.sleep(1)
