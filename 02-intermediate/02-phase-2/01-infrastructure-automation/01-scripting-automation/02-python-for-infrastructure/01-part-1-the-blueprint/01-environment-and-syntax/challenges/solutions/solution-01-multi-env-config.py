"""
Solution: Multi-Environment configuration
"""

def get_config(env_name):
    """
    Returns a merged configuration dictionary based on the environment.
    """
    BASE_CONFIG = {
        'timeout': 30,
        'retries': 3,
        'debug': False,
        'api_url': 'https://api.internal/v1'
    }
    
    ENVIRONMENT_OVERRIDES = {
        'dev': {
            'debug': True,
            'api_url': 'http://localhost:8080'
        },
        'staging': {
            'timeout': 60
        },
        'prod': {
            'retries': 10
        }
    }
    
    # Default to 'dev' if unknown
    target_env = env_name if env_name in ENVIRONMENT_OVERRIDES else 'dev'
    
    # Merge: {**base, **overrides} or .update()
    config = BASE_CONFIG.copy()
    config.update(ENVIRONMENT_OVERRIDES[target_env])
    
    return config

if __name__ == "__main__":
    import json
    print(json.dumps(get_config('prod'), indent=2))
    print(json.dumps(get_config('dev'), indent=2))
