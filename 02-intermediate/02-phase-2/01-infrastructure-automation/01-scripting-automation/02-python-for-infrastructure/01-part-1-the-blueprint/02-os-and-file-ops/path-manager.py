#!/usr/bin/env python3
"""
Topic: System and File Operations
Description: Demonstrates safe path handling and external command execution.
"""

import subprocess
import sys
from pathlib import Path

def ensure_directory(target_path: Path) -> None:
    """🛡️ Guard Clause: Pathlib implementation of mkdir -p."""
    if not target_path.exists():
        print(f"📂 Creating directory: {target_path}")
        target_path.mkdir(parents=True, exist_ok=True)
    else:
        print(f"✅ Directory already exists: {target_path}")

def run_system_audit() -> str:
    """🚀 Act: Run a shell command safely."""
    try:
        # check=True replaces manual exit code checking
        result = subprocess.run(
            ["uptime", "-p"], 
            capture_output=True, 
            text=True, 
            check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"❌ Error running audit: {e.stderr}", file=sys.stderr)
        return "N/A"

def main():
    # Standard: Use Path objects instead of strings
    work_dir = Path("/tmp/devops_audit")
    
    ensure_directory(work_dir)
    
    status = run_system_audit()
    print(f"📊 System Uptime Status: {status}")
    
    # Writing to a file using pathlib
    report_file = work_dir / "audit.txt"
    report_file.write_text(f"Uptime: {status}\n")
    print(f"📝 Report saved to {report_file}")

if __name__ == "__main__":
    main()
