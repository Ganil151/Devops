"""
Challenge: Backup Age Checker
Scenario: You have a list of backup files, but you only know their last-modified 
dates as strings. You need to flag any that are older than 30 days.

TODO: Implement `check_backup_ages(backups, max_age_days=30)`.
1. Iterate over the `backups` list.
2. For each backup, parse the 'date' string (e.g., '2026-01-01') into a `datetime` object.
3. Calculate the age: `datetime.now() - backup_date`.
4. If age > `timedelta(days=max_age_days)`, add to 'expired' list.
5. Return a report dictionary with 'healthy' and 'expired' counts.
"""
from datetime import datetime, timedelta

def check_backup_ages(backups, max_age_days=30):
    """
    Identifies backups that have exceeded the retention threshold.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    backups = [
        {"name": "production_db_01.gz", "date": "2025-12-01"},
        {"name": "production_db_02.gz", "date": "2026-01-10"},
        {"name": "staging_db.gz", "date": "2026-01-12"}
    ]
    
    report = check_backup_ages(backups, max_age_days=30)
    print(f"Healthy: {report['healthy_count']}")
    print(f"Expired: {len(report['expired_backups'])}")
    for b in report['expired_backups']:
        print(f"  - {b}")
