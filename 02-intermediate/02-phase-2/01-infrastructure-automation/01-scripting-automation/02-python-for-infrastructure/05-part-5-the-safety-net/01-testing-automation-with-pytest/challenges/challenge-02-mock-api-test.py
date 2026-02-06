"""
Challenge: Mocking API Responses
Scenario: You have a function `send_alert(msg, webhook_url)` that using 
`requests.post`. You want to test how it handles different status codes 
without actually sending Slack messages.

TODO: Implement `test_alerts.py`.
1. Use `unittest.mock.patch` to mock `requests.post`.
2. Write a test where the mock returns `status_code = 200`. Assert the 
   function returns `True`.
3. Write a test where the mock returns `status_code = 403`. Assert the 
   function returns `False` or raises an error.
4. Write a test where the mock raises a `Timeout` exception. Handle it.
"""
import pytest
import requests
from unittest.mock import patch

def send_alert(msg, url):
    try:
        resp = requests.post(url, json={"text": msg}, timeout=2)
        return resp.status_code == 200
    except requests.exceptions.Timeout:
        return False

# --- START YOUR TESTS HERE ---
def test_send_alert_success():
    # --- START YOUR CODE HERE ---
    pass
