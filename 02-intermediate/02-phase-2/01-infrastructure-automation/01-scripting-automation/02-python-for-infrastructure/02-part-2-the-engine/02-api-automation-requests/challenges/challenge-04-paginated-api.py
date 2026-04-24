"""
Challenge: Paginated API Consumer
Scenario: You are fetching build logs from a CI/CD system. The API returns 
results in pages of 10. To get the full history, you must iterate 
through all pages until no more results are returned.

TODO: Implement `fetch_all_pages(base_url)`.
1. Use a loop to fetch results page by page (e.g., `?page=1`, `?page=2`).
2. Collect the items from each page into a single `master_list`.
3. Stop when a page is empty OR the API returns a 404/error.
4. Return the `master_list`.
"""
import requests

def fetch_all_pages(base_url):
    """
    Aggregates results from a paginated API.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test with a known paginated endpoint or mock
    # Example: GitHub commits API
    URL = "https://api.github.com/repos/pallets/flask/commits"
    # To save time/quota, maybe only fetch first 3 pages
    all_data = fetch_all_pages(URL)
    print(f"Total items fetched: {len(all_data)}")
