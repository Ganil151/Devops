"""
Solution: Paginated API Consumer
"""
import requests

def fetch_all_pages(base_url):
    master_list = []
    page = 1
    
    while True:
        # Pass page as query parameter
        response = requests.get(base_url, params={"page": page, "per_page": 100})
        
        # Check if request was successful
        if response.status_code != 200:
            break
            
        data = response.json()
        
        # If no data returned, we've reached the end
        if not data:
            break
            
        master_list.extend(data)
        print(f"Fetched page {page}... (Total so far: {len(master_list)})")
        
        # Safety limit for testing (e.g., max 5 pages)
        if page >= 5:
            break
            
        page += 1
        
    return master_list

if __name__ == "__main__":
    # Test logic
    pass
