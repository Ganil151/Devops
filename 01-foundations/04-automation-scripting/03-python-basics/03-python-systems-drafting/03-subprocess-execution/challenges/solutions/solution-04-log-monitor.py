"""
Solution: Log File Monitor
"""
import subprocess
import sys

def monitor_log(log_path, pattern):
    """Monitors log file in real-time using Popen."""
    print(f"📡 Monitoring {log_path} for pattern: '{pattern}'")
    print("Press Ctrl+C to stop.")
    
    try:
        # Popen allows us to stream output as it happens
        process = subprocess.Popen(
            ["tail", "-f", log_path],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        # Stream lines from stdout
        for line in process.stdout:
            if pattern in line:
                print(f"🚨 ALERT: {line.strip()}")
                sys.stdout.flush() # Force print to terminal immediately
                
    except KeyboardInterrupt:
        print("\n✅ Stopped monitoring.")
        process.terminate()
    except FileNotFoundError:
        print(f"❌ Error: File '{log_path}' or 'tail' command not found.")

if __name__ == "__main__":
    # Test stub
    # monitor_log("app.log", "ERROR")
    pass
