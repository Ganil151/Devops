"""
Data Structures Demo: Multi-Cloud Drift Detector
-----------------------------------------------
This script demonstrates:
1. Sets for instant drift detection and membership testing.
2. Dictionaries for hierarchical state mapping.
3. List Comprehensions for efficient data transformation.
"""

from typing import Set, Dict, List

def calculate_infrastructure_drift(cloud_state: Set[str], config_state: Set[str]) -> Dict[str, Set[str]]:
    """
    Uses Set mathematics to identify state differences.
    - Intersection (&): Resources in both states.
    - Difference (-): Resources missing or untracked.
    """
    return {
        "verified": cloud_state & config_state,      # Confirmed resources
        "missing": config_state - cloud_state,       # Defined in code, not in cloud
        "untracked": cloud_state - config_state      # In cloud, but not in code (Drift!)
    }

def format_report(drift_results: Dict[str, Set[str]]) -> None:
    """
    Formats results for the CLI. Demonstrates Dictionary iteration 
    and List Comprehensions.
    """
    for status, resources in drift_results.items():
        # Clean up resource IDs for display using list comprehension
        # (e.g., lowercase names and adds a prefix)
        display_names = [res.lower() for res in resources]
        
        print(f"\n--- {status.upper()} ({len(resources)}) ---")
        
        if not display_names:
            print("  [No resources found]")
        else:
            # Sorted output for consistency
            for name in sorted(display_names):
                print(f"  [x] {name}")

# --- Execution ---
if __name__ == "__main__":
    # 1. Sets: Best for uniqueness and math operations
    # Represents IDs returned by a Cloud API
    cloud_resources: Set[str] = {
        "WEB-SERVER-01", "WEB-SERVER-02", "DB-PRIMARY", "TEST-TEMP-NODE"
    }
    
    # Represents IDs defined in a GitOps configuration file
    gitops_config: Set[str] = {
        "WEB-SERVER-01", "WEB-SERVER-02", "WEB-SERVER-03", "DB-PRIMARY"
    }

    print("Initiating Global Infrastructure Drift Analysis...")
    
    # 2. Perform Analysis
    analysis = calculate_infrastructure_drift(cloud_resources, gitops_config)
    
    # 3. Print Report
    format_report(analysis)
    
    # Advanced: Union Operation (|)
    # Total unique resources touched across all environments
    all_managed = cloud_resources | gitops_config
    print(f"\nTotal unique inventory items: {len(all_managed)}")
