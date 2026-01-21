"""
Challenge: Log Rotation Script
Scenario: Create a function to rotate log files to prevent them from growing too large.

TODO: Implement `rotate_logs(log_file, keep_count=5)` function:
1. Rename current.log to current.log.1
2. Rename current.log.1 to current.log.2, and so on.
3. Keep only the last N rotations (delete the oldest if it exceeds keep_count).
4. Create a new empty current.log file.
"""
import os

def rotate_logs(log_file, keep_count=5):
    """Rotate log files, keeping last N versions."""
    # --- START YOUR CODE HERE ---
    pass

# Test your code
if __name__ == "__main__":
    test_log = "myapp.log"
    # Create dummy log if not exists
    with open(test_log, "w") as f:
        f.write("New log entries...")
    
    rotate_logs(test_log, keep_count=3)
    print("Files in current directory:", [f for f in os.listdir(".") if test_log in f])
