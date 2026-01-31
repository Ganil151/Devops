"""
Challenge: Graceful Shutdown Handler
Scenario: Long-running automation scripts (like workers) need to clean up resources 
(delete temp files, close DB connections) when they are terminated by the OS.

TODO: Implement a graceful shutdown.
1. Use the `signal` module to register a handler for `SIGINT` (Ctrl+C).
2. Inside the handler, print "Cleaning up..." and delete a dummy file 'active_task.lock'.
3. Use a `while True` loop to simulate a running script.
4. The script should exit cleanly (status 0) after cleanup.
"""
import signal
import sys
import os
import time

def cleanup_handler(signum, frame):
    """
    Handles termination signals and performs cleanup.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Create a dummy lock file
    with open("active_task.lock", "w") as f:
        f.write("Task in progress")
        
    print("Script running... Press Ctrl+C to stop.")
    # Register the signal
    # --- START YOUR CODE HERE ---
    
    # Stay alive
    try:
        while True:
            time.sleep(1)
    except Exception as e:
        print(f"Error: {e}")
