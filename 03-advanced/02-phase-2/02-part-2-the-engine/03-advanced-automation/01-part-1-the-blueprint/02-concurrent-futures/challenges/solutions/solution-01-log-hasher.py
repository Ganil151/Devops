"""
Solution: Parallel Log Hasher
"""
from concurrent.futures import ProcessPoolExecutor
import hashlib
import time

def compute_hash(data):
    # Simulate slightly more work
    time.sleep(0.01) 
    return hashlib.sha256(data).hexdigest()

if __name__ == "__main__":
    logs = [b"log data part " + str(i).encode() for i in range(100)]
    
    start = time.perf_counter()
    with ProcessPoolExecutor() as executor:
        hashes = list(executor.map(compute_hash, logs))
        
    print(f"Computed {len(hashes)} hashes.")
    print(f"Time: {time.perf_counter() - start:.2f}s")
