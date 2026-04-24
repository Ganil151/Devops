"""
Solution: Parameterize Infrastructure Tests
"""
import pytest

def is_valid_internal_ip(ip):
    return ip.startswith("10.") or ip.startswith("192.168.")

@pytest.mark.parametrize("ip, expected", [
    ("10.0.0.1", True),
    ("192.168.1.1", True),
    ("8.8.8.8", False),
    ("1.1.1.1", False),
    ("172.16.0.1", False), # simplified logic in function
])
def test_ip_validation(ip, expected):
    assert is_valid_internal_ip(ip) == expected
