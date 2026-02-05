"""
Challenge: Function Profiler
Scenario: You want to identify which automation functions are the slowest. 
Instead of adding print(time) everywhere, use a decorator.

TODO: Implement `@profile` decorator.
1. Capture the start time.
2. Run the original function.
3. Capture the end time.
4. Log: "Function {name} took {delta} seconds."
5. Ensure you use `functools.wraps`.
"""
import time
import functools

def profile(func):
    """
    Decorator that profile function execution time.
    """
    # --- START YOUR CODE HERE ---
    pass

@profile
def slow_automation_task():
    time.sleep(2)
    print("Task Complete.")

if __name__ == "__main__":
    slow_automation_task()
