"""
Solution: Maintenance Window Scheduler
"""
from datetime import datetime, timedelta

def schedule_maintenance(start_dt):
    """Avoids weekends for maintenance scheduling."""
    # 0 = Monday, 5 = Saturday, 6 = Sunday
    wd = start_dt.weekday()
    rescheduled = False
    
    final_start = start_dt
    if wd == 5: # Saturday
        final_start = start_dt + timedelta(days=2)
        rescheduled = True
    elif wd == 6: # Sunday
        final_start = start_dt + timedelta(days=1)
        rescheduled = True
        
    final_end = final_start + timedelta(hours=4)
    
    return {
        "start": final_start,
        "end": final_end,
        "is_rescheduled": rescheduled
    }

if __name__ == "__main__":
    sat = datetime(2026, 1, 10, 22, 0, 0)
    print(schedule_maintenance(sat))
