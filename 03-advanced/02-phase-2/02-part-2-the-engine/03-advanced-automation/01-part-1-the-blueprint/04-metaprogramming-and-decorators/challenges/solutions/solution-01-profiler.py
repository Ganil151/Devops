"""
Solution: Function Profiler
"""
import time
import functools

def profile(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        end = time.perf_counter()
        print(f"DEBUG: Function '{func.__name__}' took {end - start:.4f}s")
        return result
    return wrapper

if __name__ == "__main__":
    pass
