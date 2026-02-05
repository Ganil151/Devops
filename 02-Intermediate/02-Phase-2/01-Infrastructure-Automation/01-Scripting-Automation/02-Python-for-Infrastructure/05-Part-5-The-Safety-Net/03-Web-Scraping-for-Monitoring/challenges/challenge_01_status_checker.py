"""
Challenge: Web Status Monitor
Scenario: You want to monitor a cloud provider's status page. 
The page has several `<div class="service-row">` elements, each containing 
a service name and a status.

TODO: Implement `audit_site_status(url)`.
1. Use `requests.get()` to fetch the HTML.
2. Use `BeautifulSoup` to find all `div` elements with class `service-row`.
3. Extract the text of the `name` and `status` inside each row.
4. If the status is not "Operational", add it to a `down_services` list.
5. Return the list.
"""
import requests
from bs4 import BeautifulSoup

def audit_site_status(url):
    """
    Scrapes a status page and finds non-operational services.
    """
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Test would run against a live site or mock
    pass
