"""
Solution: Web Status Monitor
"""
import requests
from bs4 import BeautifulSoup

def audit_site_status(url):
    try:
        response = requests.get(url, timeout=5)
        response.raise_for_status()
    except Exception as e:
        print(f"Failed to fetch page: {e}")
        return []
        
    soup = BeautifulSoup(response.text, 'html.parser')
    down_services = []
    
    # Logic based on common status page structure
    rows = soup.find_all('div', class_='service-row')
    for row in rows:
        name = row.find('span', class_='name').text.strip()
        status = row.find('span', class_='status').text.strip()
        
        if status.lower() != "operational":
            down_services.append({"name": name, "status": status})
            
    return down_services

if __name__ == "__main__":
    pass
