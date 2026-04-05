import pytest
from unittest.mock import patch, MagicMock
from src.health import check_http, check_ping

@patch('requests.get')
def test_check_http_success(mock_get):
    """Test HTTP check success (200 OK)"""
    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_get.return_value = mock_response
    
    assert check_http("http://example.com") is True

@patch('requests.get')
def test_check_http_failure(mock_get):
    """Test HTTP check failure (404)"""
    mock_response = MagicMock()
    mock_response.status_code = 404
    mock_get.return_value = mock_response
    
    assert check_http("http://example.com") is False

@patch('subprocess.run')
def test_check_ping_success(mock_run):
    """Test Ping check success"""
    mock_run.return_value.returncode = 0
    assert check_ping("8.8.8.8") is True

@patch('subprocess.run')
def test_check_ping_failure(mock_run):
    """Test Ping check failure"""
    mock_run.return_value.returncode = 1
    assert check_ping("1.2.3.4") is False
