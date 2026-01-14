"""
Challenge: Bulk Async Pinger
Scenario: You need to verify the availability of 50 internal service URLs. 
A sequential script takes too long. Use aiohttp to do it concurrently.

TODO: Implement `fetch_status(session, url)`.
1. Make an async GET request to the URL.
2. Return a tuple: (url, status_code).
3. Implement `main()`.
4. Create a list of 5 test URLs.
5. Use `asyncio.gather` to run the fetches concurrently.
6. Print the results.
"""
import asyncio
import aiohttp
import time

async def fetch_status(session, url):
    """
    Asynchronously fetches a URL's status code.
    """
    # --- START YOUR CODE HERE ---
    pass

async def main():
    urls = [
        "https://google.com",
        "https://github.com",
        "https://aws.amazon.com",
        "https://python.org",
        "https://kubernetes.io"
    ]
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    start = time.perf_counter()
    asyncio.run(main())
    end = time.perf_counter()
    print(f"Total time taken: {end - start:.2f}s")
