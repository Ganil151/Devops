import argparse
import sys
import yaml
import json
from pathlib import Path
from src.utils import setup_logging
from src.health import check_http, check_ping

def load_inventory(config_path: str):
    """
    Loads the server inventory from a YAML file.
    """
    path = Path(config_path)
    if not path.exists():
        raise FileNotFoundError(f"Configuration file not found: {config_path}")
    
    with open(path, "r") as f:
        return yaml.safe_load(f)

def run_health_checks(inventory, logger):
    """
    Orchestrates the health checks for all servers in the inventory.
    """
    results = []
    logger.info(f"🚀 Starting health checks for {len(inventory['servers'])} targets...")
    
    for server in inventory['servers']:
        name = server.get('name', 'Unknown')
        server_type = server.get('type')
        status = "UNKNOWN"

        if server_type == 'http':
            url = server.get('url')
            if check_http(url):
                status = "UP"
            else:
                status = "DOWN"
        
        elif server_type == 'ping':
            ip = server.get('ip')
            if check_ping(ip):
                status = "UP"
            else:
                status = "DOWN"
        
        logger.info(f"Result: {name} [{server_type}] -> {status}")
        results.append({
            "name": name,
            "type": server_type,
            "status": status
        })
    
    return results

def save_report(results, output_path: str, logger):
    """
    Saves the check results to a JSON report.
    """
    path = Path(output_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(path, "w") as f:
        json.dump(results, f, indent=4)
    
    logger.info(f"✅ Report saved to: {output_path}")

def main():
    # 1. Setup CLI Arguments
    parser = argparse.ArgumentParser(description="OpsMate: Standardized Infrastructure Health Checker")
    parser.add_argument("--config", default="config/inventory.yaml", help="Path to inventory YAML")
    parser.add_argument("--output", default="reports/health_report.json", help="Path to save JSON report")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose logging")
    
    args = parser.parse_args()

    # 2. Initialize Logging
    logger = setup_logging()
    if args.verbose:
        logger.handlers[0].setLevel(logging.DEBUG) # Set console to DEBUG

    try:
        # 3. Load Config
        inventory = load_inventory(args.config)

        # 4. Run Checks
        results = run_health_checks(inventory, logger)

        # 5. Save Report
        save_report(results, args.output, logger)

        # 6. Exit Strategy
        any_down = any(r['status'] == "DOWN" for r in results)
        if any_down:
            logger.error("❌ Some health checks failed!")
            sys.exit(1)
        
        logger.info("🟢 All systems operational.")
        sys.exit(0)

    except Exception as e:
        logger.critical(f"💥 Fatal Error: {e}")
        sys.exit(2)

if __name__ == "__main__":
    main()
