"""
Infrastructure Drift Detector
Description: Compares provisioned infrastructure (Terraform state) with Live state.
Output: Unified JSON Drift Report.
"""

import os
import json
import subprocess
import logging
from pathlib import Path

# Advanced Logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s [%(levelname)s] %(message)s')
logger = logging.getLogger(__name__)

class DriftDetector:
    def __init__(self, workspace_path):
        self.path = Path(workspace_path)
        
    def check_terraform_drift(self):
        """Analyzes Terraform drift via plan -detailed-exitcode."""
        logger.info(f"Targeting Terraform Workspace: {self.path}")
        
        try:
            # -detailed-exitcode: 2 means drift, 0 means no drift
            result = subprocess.run(
                ["terraform", "plan", "-detailed-exitcode", "-refresh-only"],
                cwd=self.path,
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                return {"status": "SUCCESS", "drift": False, "details": "State matches provider."}
            elif result.returncode == 2:
                return {"status": "DRIFT", "drift": True, "details": "External changes detected!"}
            else:
                return {"status": "ERROR", "drift": True, "details": result.stderr}
                
        except FileNotFoundError:
            return {"status": "ERROR", "details": "Terraform binary not found."}

def main():
    # Example targeting a specific module in Phase 2
    repo_root = Path(os.getcwd())
    tf_dir = repo_root / "02-Phase-2" / "11-Cloud-Architecture" / "Terraform"
    
    if not tf_dir.exists():
        logger.warning(f"TF directory {tf_dir} not found. Running in simulation mode.")
        drift_report = {"summary": "No live TF detected. Simulation mode.", "drift_percentage": 0}
    else:
        detector = DriftDetector(tf_dir)
        drift_report = detector.check_terraform_drift()

    # Output structured results for CI parsing
    print(json.dumps(drift_report, indent=2))

if __name__ == "__main__":
    main()
