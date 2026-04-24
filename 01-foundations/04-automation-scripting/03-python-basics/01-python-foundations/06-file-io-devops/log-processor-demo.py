"""
File Operations Demo: Streaming Log Processor
--------------------------------------------
This script demonstrates:
1. Safe file handling using context managers (`with`).
2. Memory-efficient streaming (reading line-by-line).
3. Writing structured results to a persistent file.
"""

from pathlib import Path

# --- Configuration ---
SOURCE_FILE = Path("input_logs.txt")
REPORT_FILE = Path("error_report.txt")

def generate_mock_logs():
    """Helper to create a sample log file if it doesn't exist."""
    logs = [
        "2026-01-30 [INFO] System boot complete.\n",
        "2026-01-30 [ERROR] Connection timed out on port 5432.\n",
        "2026-01-30 [INFO] User login: jdoe.\n",
        "2026-01-30 [ERROR] Permission denied on /etc/shadow.\n",
        "2026-01-31 [WARNING] Disk usage above 80%.\n"
    ]
    SOURCE_FILE.write_text("".join(logs))
    print(f"Created sample log: {SOURCE_FILE}")

def process_logs():
    """
    Reads from SOURCE_FILE and writes errors to REPORT_FILE.
    Demonstrates efficient streaming.
    """
    error_count = 0
    
    # 1. Open both files safely using context managers
    with open(SOURCE_FILE, "r") as src, open(REPORT_FILE, "w") as report:
        report.write("--- AUTOMATED ERROR REPORT ---\n")
        
        # 2. Iterate line-by-line (DO NOT use .readlines() for huge files!)
        for line in src:
            if "[ERROR]" in line:
                error_count += 1
                # 3. Clean and write the finding
                timestamp = line.split(" ")[0]
                message = line.split("[ERROR]")[1].strip()
                report.write(f"- {timestamp}: {message}\n")
                
    print(f"Processing complete. Found {error_count} errors.")
    print(f"Report saved to: {REPORT_FILE.absolute()}")

# --- Execution ---
if __name__ == "__main__":
    # Ensure source exists
    if not SOURCE_FILE.exists():
        generate_mock_logs()
        
    process_logs()

    # Showcase pathlib features
    print(f"\nSource File Stats:")
    print(f" - Extension: {SOURCE_FILE.suffix}")
    print(f" - Size: {SOURCE_FILE.stat().st_size} bytes")
