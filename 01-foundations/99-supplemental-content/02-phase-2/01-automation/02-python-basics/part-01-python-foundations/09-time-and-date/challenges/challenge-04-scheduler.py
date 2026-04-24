"""
Challenge: Maintenance Window Scheduler
Scenario: You need to schedule a 4-hour maintenance window. However, you must avoid 
weekends (Saturday and Sunday). If the calculated window falls on a weekend, 
move it to the following Monday at the same time.

TODO: Implement `schedule_maintenance(start_dt)`.
1. Calculate the end time (start_dt + 4 hours).
2. Check the weekday of `start_dt` using `.weekday()` (0=Monday, 6=Sunday).
3. If it's Saturday (5) or Sunday (6):
   - Shift the `start_dt` to the next Monday. (If Sat, add 2 days; if Sun, add 1).
   - Recalculate the end time.
4. Return a dictionary with 'start', 'end', and 'is_rescheduled' (bool).
"""
from datetime import datetime, timedelta

def schedule_maintenance(start_dt):
    """
    Ensures maintenance windows only occur on weekdays.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test Saturday
    sat_start = datetime(2026, 1, 17, 10, 0, 0) # Saturday
    window = schedule_maintenance(sat_start)
    print(f"Original Sat -> Shifted to: {window['start'].strftime('%A, %Y-%m-%d')}")
    
    # Test Monday
    mon_start = datetime(2026, 1, 19, 10, 0, 0) # Monday
    window = schedule_maintenance(mon_start)
    print(f"Original Mon -> Kept as:    {window['start'].strftime('%A, %Y-%m-%d')}")
