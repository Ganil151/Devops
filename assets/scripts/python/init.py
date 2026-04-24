from .loader import load_from_env
from .settings import Settings

# Initialize and validate on import (12-Factor style)
env_data = load_from_env()
config = Settings(env_data)

# Usually we might wait for explicit validation call, 
# but for challenge we can show it here.
# config.validate() 
