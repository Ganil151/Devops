"""
Challenge: Unit Test for Config Loader
Scenario: You have a function `load_env_config(path)` that reads a 
YAML file and returns a dictionary. You need to test it thoroughly.

TODO: Implement `test_config.py`.
1. Create a function `load_env_config(path)` in a file (or mock it).
2. Create a `@pytest.fixture` that generates a temporary 'config.yaml' 
   file before the test and deletes it after.
3. Write a test `test_valid_load` that asserts the returned data is correct.
4. Write a test `test_missing_file` that asserts `FileNotFoundError` is raised.
"""
import pytest
import yaml
import os

# --- YOU CAN PUT THE FUNCTION TO TEST HERE ---
def load_env_config(path):
    with open(path, 'r') as f:
        return yaml.safe_load(f)

# --- START YOUR TESTS HERE ---
@pytest.fixture
def sample_config_file():
    # Setup
    pass

def test_valid_load(sample_config_file):
    pass
