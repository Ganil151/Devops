"""
Challenge: SLA Duration Calculator
Scenario: You are tracking incident resolution times. Your SLA (Service Level 
Agreement) requires incidents to be resolved within 4 hours.

TODO: Implement `check_sla_compliance(start_str, end_str)`.
1. Parse both strings into `datetime` objects. (Format: `%Y-%m-%d %H:%M:%S`).
2. Subtract start from end to get a `timedelta`.
3. Calculate the total duration in hours.
4. Return a dictionary containing:
   - 'duration_minutes'
   - 'is_compliant' (True if <= 4 hours, False otherwise)
"""
from datetime import datetime, timedelta

def check_sla_compliance(start_str, end_str):
    """
    Calculates resolution time and checks against a 4-hour SLA.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test cases
    print(check_sla_compliance("2026-01-12 10:00:00", "2026-01-12 12:30:00")) # Compliant
    print(check_sla_compliance("2026-01-12 10:00:00", "2026-01-12 15:00:00")) # Breached
