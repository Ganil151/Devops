"""
Solution: Bulk Async Pinger
"""
import asyncio
import aiohttp

async def fetch_status(session, url):
    try:
        async with session.get(url, timeout=5) as response:
            return url, response.status
    except Exception as e:
        return url, f"Error: {e}"

async def main():
    urls = [
        "https://google.com",
        "https://github.com",
        "https://aws.amazon.com",
        "https://python.org",
        "https://kubernetes.io"
    ]
    
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_status(session, url) for url in urls]
        results = await asyncio.gather(*tasks)
        
        for url, status in results:
            print(f"{url:<25} | Status: {status}")

if __name__ == "__main__":
    import time
    start = time.perf_counter()
    asyncio.run(main())
    print(f"Time: {time.perf_counter() - start:.2f}s")
