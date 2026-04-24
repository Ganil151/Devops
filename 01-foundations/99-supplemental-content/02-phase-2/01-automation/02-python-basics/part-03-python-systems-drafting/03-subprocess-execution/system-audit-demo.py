"""
Subprocess Demo: System Diagnostic Auditor
------------------------------------------
This script demonstrates the professional way to bridge Python and the Shell.
1. subprocess.run() for synchronous one-shot commands.
2. capture_output=True for parsing command results.
3. check=True for strict error handling and pipeline safety.
4. The "List Pattern" for preventing shell injection vulnerabilities.
"""

import subprocess
import os

def run_system_audit():
    print("🚀 Initializing Diagnostic Subprocess Pipeline...")

    # 1. Capture and Parse Output
    try:
        print("\n[Action 1] Checking Local Disk Health...")
        # 'df -h' is a standard Linux command for disk usage
        # We target the root '/' partition
        result = subprocess.run(
            ["df", "-h", "/"],
            capture_output=True, # Saves stdout/stderr to the result object
            text=True,           # Decodes bytes to string automatically
            check=True           # Raises exception if exit code is non-zero
        )
        
        # Demonstrating how to parse the result
        lines = result.stdout.strip().splitlines()
        if len(lines) > 1:
            header = lines[0]
            data = lines[1]
            print(f"  Result: {data}")
            
    except subprocess.CalledProcessError as e:
        print(f"  ❌ Failed to check disk: {e.stderr}")

    # 2. Resilient Connectivity Check
    print("\n[Action 2] Verifying Global Connectivity (Ping 8.8.8.8)...")
    try:
        # We limit to 2 pings for speed
        subprocess.run(
            ["ping", "-c", "2", "8.8.8.8"],
            check=True,
            capture_output=True # We capture but don't print, we just care about return code
        )
        print("  ✅ Connectivity: STABLE")
    except subprocess.CalledProcessError:
        print("  ❌ Connectivity: OFFLINE or TIMEOUT")

    # 3. Security: The Shell Injection Guard
    # We simulate a "dirty" input from a user or external API
    malicious_input = "test.txt; rm -rf /root"
    print(f"\n[Action 3] Security Test: Processing filename '{malicious_input}'")
    
    try:
        # In a bad script (shell=True), this would try to delete /root
        # In this professional script, it will fail because no file actually has that name
        subprocess.run(
            ["ls", "-l", malicious_input],
            check=True,
            capture_output=True,
            text=True
        )
    except subprocess.CalledProcessError:
        print("  🛡️  Security: Shell Injection Blocked. Command treated as a literal (invalid) string.")

def stream_realtime_logs():
    """
    Demonstrates Popen for long-running processes (Streaming Output).
    """
    print("\n[Action 4] Real-Time Stream (Listing /etc/hosts)...")
    
    # Popen doesn't wait; it starts the process and returns a handle
    process = subprocess.Popen(
        ["cat", "/etc/hosts"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    # Stream the output line-by-line as it's generated
    if process.stdout:
        for line in process.stdout:
            print(f"  [STREAM]: {line.strip()}")

    process.wait() # Ensure we sync up before finishing
    print("  ✅ Stream Complete.")

if __name__ == "__main__":
    run_system_audit()
    stream_realtime_logs()
