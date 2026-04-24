#!/usr/bin/env python3
"""
Topic: Testing Automation with Pytest
Description: Demonstrates unit testing for a DevOps utility.
"""

import pytest

# The function we want to test
def calculate_backoff(retry_count: int) -> int:
    """Calculates exponential backoff: 2, 4, 8, 16..."""
    if retry_count < 0:
        raise ValueError("Retry count cannot be negative")
    return 2 ** (retry_count + 1)

# --- Test Suite ---

def test_backoff_progression():
    """✅ Verify the math for the first 3 retries."""
    assert calculate_backoff(0) == 2
    assert calculate_backoff(1) == 4
    assert calculate_backoff(2) == 8

def test_backoff_negative_input():
    """🛡️ Verify the guard clause raises an exception."""
    with pytest.raises(ValueError, match="cannot be negative"):
        calculate_backoff(-1)

# Usage: Run 'pytest test_infra_logic.py' from the terminal
