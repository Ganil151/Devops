"""
Solution: SLA Duration Calculator
"""
from datetime import datetime, timedelta

def check_sla_compliance(start_str, end_str):
    """Checks if incident resolution was within 4h SLA."""
    fmt = "%Y-%m-%d %H:%M:%S"
    start = datetime.strptime(start_str, fmt)
    end = datetime.strptime(end_str, fmt)
    
    duration = end - start
    total_minutes = duration.total_seconds() / 60
    
    # 4 hours = 240 minutes
    is_compliant = total_minutes <= 240
    
    return {
        "duration_minutes": total_minutes,
        "is_compliant": is_compliant
    }

if __name__ == "__main__":
    print(check_sla_compliance("2026-01-12 10:00:00", "2026-01-12 12:00:00"))
    print(check_sla_compliance("2026-01-12 10:00:00", "2026-01-12 15:01:00"))
