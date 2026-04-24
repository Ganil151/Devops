"""
Solution: Backup Age Checker
"""
from datetime import datetime, timedelta

def check_backup_ages(backups, max_age_days=30):
    """Flags backups older than max_age_days."""
    now = datetime.now()
    max_age = timedelta(days=max_age_days)
    expired = []
    healthy_count = 0
    
    for backup in backups:
        # Parse date string
        b_date = datetime.strptime(backup["date"], "%Y-%m-%d")
        
        # Calculate age
        age = now - b_date
        
        if age > max_age:
            expired.append(backup["name"])
        else:
            healthy_count += 1
            
    return {
        "healthy_count": healthy_count,
        "expired_backups": expired
    }

if __name__ == "__main__":
    backups = [
        {"name": "old_db.gz", "date": "1999-01-01"},
        {"name": "new_db.gz", "date": (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")}
    ]
    print(check_backup_ages(backups))
