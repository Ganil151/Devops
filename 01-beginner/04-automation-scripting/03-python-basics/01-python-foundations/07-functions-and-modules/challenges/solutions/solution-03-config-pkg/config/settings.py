class Settings:
    REQUIRED_KEYS = ["API_KEY", "DB_HOST"]
    
    DEFAULTS = {
        "TIMEOUT": 30,
        "DEBUG": False,
        "REGION": "us-east-1"
    }
    
    def __init__(self, env_data):
        # 1. Load Defaults
        for key, value in self.DEFAULTS.items():
            setattr(self, key, value)
            
        # 2. Override with Env Data
        for key, value in env_data.items():
            setattr(self, key, value)

    def validate(self):
        # 3. Check Required Keys
        missing = [k for k in self.REQUIRED_KEYS if not hasattr(self, k)]
        if missing:
            raise ValueError(f"Missing required config vars: {missing}")
