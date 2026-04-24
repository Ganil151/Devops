"""
Solution: Mocking API Responses
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

# The Tests
@patch('requests.post')
def test_send_alert_success(mock_post):
    # Setup mock
    mock_post.return_value.status_code = 200
    
    # Act
    result = send_alert("hello", "http://fake.url")
    
    # Assert
    assert result is True
    mock_post.assert_called_once()

@patch('requests.post')
def test_send_alert_forbidden(mock_post):
    mock_post.return_value.status_code = 403
    result = send_alert("hello", "http://fake.url")
    assert result is False

@patch('requests.post')
def test_send_alert_timeout(mock_post):
    # Simulate an exception
    mock_post.side_effect = requests.exceptions.Timeout()
    result = send_alert("hello", "http://fake.url")
    assert result is False
