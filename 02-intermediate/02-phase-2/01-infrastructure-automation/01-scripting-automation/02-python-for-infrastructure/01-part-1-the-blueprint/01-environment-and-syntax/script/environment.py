import subprocess
import sys
import shutil
from pathlib import Path

# Configuration
VENV_DIR = Path(".venv_temp")


def main():
    print("🚀 Starting Ephemeral Task Runner...")

    # 1. Clean start: Ensure directory doesn't exist
    if VENV_DIR.exists():
        print(f"   Removing existing {VENV_DIR}...")
        shutil.rmtree(VENV_DIR)

    # 2. Create Virtual Environment
    print(f"📦 Creating isolated environment at {VENV_DIR}...")
    # Uses the current python interpreter to create the new one
    subprocess.run([sys.executable, "-m", "venv", str(VENV_DIR)], check=True)

    # Define paths to the venv binaries (Linux/Mac structure)
    venv_python = VENV_DIR / "bin" / "python"

    # 3. Install dependencies inside the venv
    print("⬇️  Installing 'tabulate' library...")
    subprocess.run(
        [str(venv_python), "-m", "pip", "install", "tabulate", "-q"], check=True
    )

    # 4. Run the task using the ISOLATED python
    print("✅ Running task inside the bubble...")
    task_code = """
from tabulate import tabulate
servers = [
    ["app-01", "10.0.1.5", "Active"],
    ["db-01", "10.0.2.10", "Maintenance"],
    ["cache-01", "10.0.3.2", "Active"]
]
print(tabulate(servers, headers=["Hostname", "IP", "State"], tablefmt="grid"))
"""
    subprocess.run([str(venv_python), "-c", task_code], check=True)

    # 5. Cleanup
    print("🧹 Cleaning up: Deleting environment...")
    shutil.rmtree(VENV_DIR)
    print("✨ Execution complete. System returned to original state.")


if __name__ == "__main__":
    main()
