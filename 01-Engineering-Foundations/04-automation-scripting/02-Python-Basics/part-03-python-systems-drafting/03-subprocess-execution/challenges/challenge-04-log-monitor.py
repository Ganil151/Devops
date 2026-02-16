"""
Challenge: Log File Monitor
Scenario: You need to monitor a log file in real-time and execute a 
Python action whenever a specific error pattern is found.

TODO: Implement `monitor_log(log_path, pattern)`.
1. Use `subprocess.Popen` to run `tail -f {log_path}`.
2. Read the output stream line by line.
3. If a line contains the 'pattern', print an alert: "🚨 ALERT: {line}".
4. Allow the user to stop monitoring with Ctrl+C (KeyboardInterrupt).
"""
import subprocess
import sys

def monitor_log(log_path, pattern):
    """
    Streams a log file and searches for a pattern.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # To test:
    # 1. Start this script: python challenge_04_log_monitor.py test.log "ERROR"
    # 2. In another terminal, run: echo "This is an ERROR" >> test.log
    
    if len(sys.argv) < 3:
        print("Usage: python challenge_04_log_monitor.py <file> <pattern>")
    else:
        monitor_log(sys.argv[1], sys.argv[2])
