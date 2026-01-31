"""
Solution: Unit Test for Config Loader
"""
import pytest
import yaml
import os

# Function to test
def load_env_config(path):
    if not os.path.exists(path):
        raise FileNotFoundError("Config missing")
    with open(path, 'r') as f:
        return yaml.safe_load(f)

# The Fixture
@pytest.fixture
def temp_yaml():
    path = "test_config.yaml"
    data = {"env": "prod", "version": 1.5}
    with open(path, 'w') as f:
        yaml.dump(data, f)
    
    yield path # Run the test
    
    if os.path.exists(path):
        os.remove(path)

# The Tests
def test_valid_load(temp_yaml):
    config = load_env_config(temp_yaml)
    assert config['env'] == "prod"
    assert config['version'] == 1.5

def test_missing_file():
    with pytest.raises(FileNotFoundError):
        load_env_config("non_existent.yaml")
