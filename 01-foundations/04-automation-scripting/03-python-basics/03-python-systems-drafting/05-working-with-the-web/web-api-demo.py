"""
Web Automation Demo: API & Scraping Auditor
------------------------------------------
Demonstrates: requests, raise_for_status, JSON parsing, and BeautifulSoup scraping.
"""

import requests
from bs4 import BeautifulSoup
import sys

def check_github_status():
    """Checks the public GitHub API for health stats."""
    URL = "https://api.github.com/zen"
    print(f"\n[API] Querying GitHub for current zen...")
    
    try:
        # 1. ALWAYS use a timeout
        response = requests.get(URL, timeout=5)
        
        # 2. ENFORCE success status
        response.raise_for_status()
        
        print(f"  ✓ Success! GitHub Zen: '{response.text}'")
        return True
    except requests.exceptions.HTTPError as e:
        print(f"  ❌ API Error (HTTP): {e}")
    except requests.exceptions.ConnectionError:
        print("  ❌ API Error: Could not connect to the network.")
    except Exception as e:
        print(f"  ❌ Unexpected Failure: {e}")
    return False

def scrape_mock_portal():
    """
    Simulates scraping a status portal that has no API.
    """
    print("\n[Scraping] Analyzing Mock Legacy Status Page...")
    
    # Mock HTML (In a real scenario, this would come from requests.get().text)
    mock_html = """
    <html>
      <body>
        <h1>Internal Infrastructure Status</h1>
        <table id="status-table">
          <tr><td>Database Cluster</td><td class="status-up">OPERATIONAL</td></tr>
          <tr><td>Legacy VPN</td><td class="status-down">CRITICAL ERROR</td></tr>
          <tr><td>Jenkins CI</td><td class="status-up">OPERATIONAL</td></tr>
        </table>
      </body>
    </html>
    """
    
    soup = BeautifulSoup(mock_html, "html.parser")
    
    # Find all rows in our table
    rows = soup.find_all("tr")
    
    findings = []
    for row in rows:
        cells = row.find_all("td")
        if len(cells) == 2:
            service = cells[0].text
            status = cells[1].text
            if "CRITICAL" in status:
                findings.append(f"🚨 {service}: {status}")
            else:
                findings.append(f"✅ {service}: {status}")
                
    for f in findings:
        print(f"  {f}")

# --- Execution ---
if __name__ == "__main__":
    check_github_status()
    scrape_mock_portal()
    print("\nWeb Audit Complete.")
