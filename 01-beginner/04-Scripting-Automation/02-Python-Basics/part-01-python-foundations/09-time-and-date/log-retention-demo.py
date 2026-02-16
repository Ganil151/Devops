"""
Time and Date Demo: Log Aging & Retention Auditor
-------------------------------------------------
This script demonstrates:
1. ISO 8601 formatting for standardized logging.
2. Timedelta arithmetic for expiration checking.
3. Timezone awareness (UTC) for cloud consistency.
"""

from datetime import datetime, timezone, timedelta
from typing import List, Dict

# Configuration
RETENTION_DAYS = 30

def determine_log_age(log_timestamp_iso: str) -> timedelta:
    """
    Calculates the delta between 'now' and a log entry.
    Demonstrates ISO parsing and UTC awareness.
    """
    # Parse ISO 8601 string to datetime object
    log_time = datetime.fromisoformat(log_timestamp_iso)
    
    # Ensure both datetimes are timezone-aware (UTC) to avoid comparison errors
    now = datetime.now(timezone.utc)
    
    return now - log_time

def run_retention_audit(logs: List[Dict[str, str]]) -> None:
    """
    Audits a list of logs and marks those exceeding retention policy.
    """
    print(f"\n{'LOG SOURCE':<15} | {'AGE (DAYS)':<10} | {'STATUS'}")
    print("-" * 45)

    for entry in logs:
        age_delta = determine_log_age(entry["timestamp"])
        days_old = age_delta.days
        
        if days_old > RETENTION_DAYS:
            status = "❌ EXPIRED (Delete)"
        else:
            status = "✅ RETAIN"
            
        print(f"{entry['source']:<15} | {days_old:<10} | {status}")

# --- Execution ---
if __name__ == "__main__":
    # Simulated log metadata
    # Logs are often stored with ISO 8601 timestamps (YYYY-MM-DDTHH:MM:SS+HH:MM)
    current_utc = datetime.now(timezone.utc)
    
    sample_logs = [
        {
            "source": "auth_service", 
            "timestamp": (current_utc - timedelta(days=5)).isoformat()
        },
        {
            "source": "billing_api", 
            "timestamp": (current_utc - timedelta(days=45)).isoformat()
        },
        {
            "source": "db_monitor", 
            "timestamp": (current_utc - timedelta(days=2)).isoformat()
        }
    ]

    print(f"Log Retention Policy: {RETENTION_DAYS} Days")
    run_retention_audit(sample_logs)
    
    # Showcase ISO formatting
    print(f"\nCurrent UTC Audit Time: {current_utc.strftime('%Y-%m-%d %H:%M:%S UTC')}")
