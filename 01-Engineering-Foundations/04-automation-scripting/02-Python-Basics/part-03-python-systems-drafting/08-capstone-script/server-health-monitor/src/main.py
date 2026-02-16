import argparse
import json
import logging
import sys
from pathlib import Path
from checker import run_health_check
from reporter import generate_report

# --- 1. Setup Logging ---
def setup_logging(log_file: Path):
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        handlers=[
            logging.FileHandler(log_file),
            logging.StreamHandler(sys.stdout)
        ]
    )

# --- 2. Main Logic ---
def main():
    # CLI Argument Parsing
    parser = argparse.ArgumentParser(description="Multi-Server Health Monitor")
    parser.add_argument(
        "--config", 
        default="../config/servers.json", 
        help="Path to the server configuration file"
    )
    parser.add_argument(
        "--output", 
        help="Path to save the JSON results report"
    )
    args = parser.parse_args()

    # Define paths relative to the script location
    base_dir = Path(__file__).resolve().parent.parent
    config_path = base_dir / "config" / "servers.json" if args.config == "../config/servers.json" else Path(args.config)
    log_path = base_dir / "logs" / "monitor.log"
    
    # Initialize Logging
    setup_logging(log_path)
    logging.info("Starting Multi-Server Health Monitor...")

    # Load Configuration
    if not config_path.exists():
        logging.error(f"Configuration file not found: {config_path}")
        sys.exit(2)

    try:
        with open(config_path, 'r') as f:
            servers = json.load(f)
    except json.JSONDecodeError as e:
        logging.error(f"Failed to parse config JSON: {e}")
        sys.exit(2)

    # Execute Checks
    results = []
    for server in servers:
        logging.info(f"Checking {server.get('name')}...")
        try:
            check_result = run_health_check(server)
            results.append(check_result)
        except Exception as e:
            logging.error(f"Unexpected error checking {server.get('name')}: {e}")

    # Generate Report
    all_healthy = generate_report(results, output_file=args.output)
    
    logging.info("Monitor run complete.")

    # Return exit code: 0 if all UP, 1 if some DOWN
    sys.exit(0 if all_healthy else 1)

if __name__ == "__main__":
    main()
