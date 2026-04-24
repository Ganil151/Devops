"""
Solution: Graceful Shutdown Handler
"""
import signal
import time

class AutomationRunner:
    def __init__(self):
        self.running = True
        self.resources = []
        self._setup_signals()
    
    def _setup_signals(self):
        """Register signal handlers for graceful shutdown."""
        signal.signal(signal.SIGINT, self._handle_shutdown)
        signal.signal(signal.SIGTERM, self._handle_shutdown)
    
    def _handle_shutdown(self, signum, frame):
        """Handle shutdown signals."""
        signal_name = signal.Signals(signum).name
        print(f"\nReceived {signal_name}, initiating graceful shutdown...")
        self.running = False
    
    def acquire_resource(self, name):
        """Acquire a resource that needs cleanup."""
        print(f"Acquiring resource: {name}")
        self.resources.append(name)
    
    def cleanup(self):
        """Clean up all acquired resources."""
        print("Cleaning up resources...")
        for resource in reversed(self.resources):
            print(f"  Releasing: {resource}")
        self.resources.clear()
        print("Cleanup complete")
    
    def run(self):
        """Main execution loop."""
        try:
            self.acquire_resource("database_connection")
            self.acquire_resource("file_handle")
            self.acquire_resource("api_session")
            
            print("Starting main loop (Ctrl+C to stop)...")
            while self.running:
                print("  Working...")
                time.sleep(1)
                
        except Exception as e:
            print(f"Error during execution: {e}")
            raise
        finally:
            self.cleanup()

if __name__ == "__main__":
    runner = AutomationRunner()
    runner.run()
