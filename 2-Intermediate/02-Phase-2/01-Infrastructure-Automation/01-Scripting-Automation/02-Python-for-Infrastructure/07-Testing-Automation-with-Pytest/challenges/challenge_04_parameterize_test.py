"""
Challenge: Parameterize Infrastructure Tests
Scenario: You have a utility function `is_valid_internal_ip(ip)` that 
checks if an IP belongs to a private range (e.g., starts with 10. or 192.168.).
You need to test it against many cases.

TODO: Implement `test_network.py`.
1. Use `@pytest.mark.parametrize` to provide a list of inputs and expected outputs.
2. Test valid private IPs: "10.0.0.1" (True), "192.168.1.10" (True).
3. Test invalid/public IPs: "8.8.8.8" (False), "172.50.1.1" (False).
4. Assert the function handles all cases correctly in a single test function.
"""
import pytest

def is_valid_internal_ip(ip):
    # Very simple check for the challenge
    return ip.startswith("10.") or ip.startswith("192.168.")

# --- START YOUR TESTS HERE ---
# TODO: Add @pytest.mark.parametrize decorator
def test_ip_validation(ip, expected):
    # --- START YOUR CODE HERE ---
    pass
