default_config = {
        "timeout": 30,
        "retries": 3,
        "ssl": True,
        "port": 80,
}

production_override = {
        "port": 443,
        "timeout": 60,
        "monitoring": True
)
