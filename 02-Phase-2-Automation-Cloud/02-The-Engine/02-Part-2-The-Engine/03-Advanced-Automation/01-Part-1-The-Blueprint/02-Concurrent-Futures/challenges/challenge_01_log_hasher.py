"""
Challenge: Parallel Log Hasher
Scenario: To verify log integrity, you must hash many files. 
Hashing is CPU intensive. Using one core is slow. Use all of them.

TODO: Implement `compute_hash(file_data)`.
1. Return the SHA256 hex digest of the data.
2. Implement `main()`.
3. Generate 10 dummy byte strings (representing log content).
4. Use `concurrent.futures.ProcessPoolExecutor` to hash them.
5. Record the time taken and verify all hashes were computed.
"""
from concurrent.futures import ProcessPoolExecutor
import hashlib
import time

def compute_hash(data):
    """
    Computes SHA256 hash (CPU Bound).
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Mock data
    logs = [b"log data part " + str(i).encode() for i in range(100)]
    
    start = time.perf_counter()
    # --- START YOUR CODE HERE ---
    pass
    print(f"Finished in {time.perf_counter() - start:.2f}s")
