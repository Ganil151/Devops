"""
Challenge: Graceful Shutdown Handler
Scenario: Design a long-running automation script that cleans up its own mess when interrupted.

TODO: Implement `AutomationRunner` class logic:
1. Handle `SIGINT` (Ctrl+C) and `SIGTERM` signals.
2. Maintain a list of acquired resources.
3. Ensure `cleanup()` is ALWAYS called, even if the script crashes or is stopped.
4. Log why the shutdown was initiated.
"""
import signal
import time

class AutomationRunner:
    def __init__(self):
        self.running = True
        self.resources = []
        # --- START YOUR CODE HERE ---
    
    def acquire_resource(self, name):
        """Acquire a resource that needs cleanup."""
        print(f"Acquiring resource: {name}")
        self.resources.append(name)
    
    def cleanup(self):
        """Clean up all acquired resources."""
        # --- START YOUR CODE HERE ---
        pass
    
    def run(self):
        """Main execution loop."""
        # --- START YOUR CODE HERE ---
        pass

# Test your code
if __name__ == "__main__":
    runner = AutomationRunner()
    print("Runner starting... press Ctrl+C to stop.")
    runner.run()
