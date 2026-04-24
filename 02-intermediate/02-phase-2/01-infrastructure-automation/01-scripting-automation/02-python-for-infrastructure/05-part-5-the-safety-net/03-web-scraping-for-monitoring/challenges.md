# 🛠️ Scraping Challenges

## Challenge 1: The Price Tracker
**Objective**: Monitor a product price (Simulated).
1.  Target: `https://books.toscrape.com/catalogue/a-light-in-the-attic_1000/index.html` (Safe scraping sandbox).
2.  Find the price element (`p.price_color`).
3.  Parse the text (e.g., `£51.77`).
4.  If price < £50, print "Buy Now!".

## Challenge 2: Uptime Keyword Checker
**Objective**: Build a `healthcheck.py`.
1.  List of sites: `["site1", "site2"]`.
2.  Expected text: "Welcome" or "Status: OK".
3.  If text missing or 404, send alert (Mock print).

## Challenge 3: Mirror Maker
**Objective**: Download all images from a page.
1.  Parse `<img>` tags.
2.  Get `src` attribute.
3.  Use `requests.get(src)` and save content to file.
