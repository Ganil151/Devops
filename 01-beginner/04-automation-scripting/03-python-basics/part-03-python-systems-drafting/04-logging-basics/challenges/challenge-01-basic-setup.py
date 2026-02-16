"""
Challenge: Basic Logger Setup
Scenario: You are building a deployment script. You want to log informational 
messages to the console but keep detailed debug logs in a file named `deploy.log`.

TODO: Implement `setup_logger()`.
1. Create a logger named 'deploy'.
2. Set the global logger level to DEBUG.
3. Add a `StreamHandler` for the console (Level: INFO).
4. Add a `FileHandler` for 'deploy.log' (Level: DEBUG).
5. Use the format: `%(asctime)s - %(levelname)s - %(message)s`.
"""
import logging

def setup_logger():
    """
    Configures and returns a logger with console and file handlers.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    logger = setup_logger()
    logger.debug("This is a HIDDEN debug message (file only)")
    logger.info("This is a VISIBLE info message (console + file)")
    logger.error("This is an ERROR message")
