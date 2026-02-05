"""
Name: test_framework.py
Description: Demonstrates Pytest fixtures and assertions.
Run validation: pytest test_framework.py
"""

import pytest
import os
import tempfile

# 1. The Code to Test (Usually imported)
def calculate_risk(files_changed: int, crucial_files: bool) -> str:
    if crucial_files:
        return "HIGH"
    if files_changed > 10:
        return "MEDIUM"
    return "LOW"

class ConfigLoader:
    def __init__(self, path):
        if not os.path.exists(path):
            raise FileNotFoundError(f"Missing {path}")
        self.path = path

# 2. The Tests

def test_risk_logic():
    """Unit test for simple logic."""
    assert calculate_risk(5, False) == "LOW"
    assert calculate_risk(50, False) == "MEDIUM"
    assert calculate_risk(1, True) == "HIGH"

# 3. Fixtures (Setup/Teardown)

@pytest.fixture
def dummy_config():
    """Creates a temporary file for the test duration."""
    with tempfile.NamedTemporaryFile(delete=False) as tmp:
        tmp.write(b"key=value")
        path = tmp.name
    
    yield path # Test runs here
    
    # Teardown
    os.remove(path)

def test_config_loader(dummy_config):
    """Integration test using filesystem."""
    loader = ConfigLoader(dummy_config)
    assert loader.path == dummy_config

def test_config_missing():
    """Exception testing."""
    with pytest.raises(FileNotFoundError):
        ConfigLoader("/nonexistent/file.conf")
