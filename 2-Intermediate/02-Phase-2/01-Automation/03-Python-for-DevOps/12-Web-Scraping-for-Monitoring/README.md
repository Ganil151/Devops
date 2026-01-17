# Web Scraping for Monitoring

Sometimes an API doesn't exist. "Blackbox Monitoring" involves checking the user-facing HTML to ensure the site actually works. `BeautifulSoup` makes parsing HTML easy.

## 📚 Module Structure
- **[Boilerplates](./Boilerplates/)**: `monitor.py` (Keyword Checker).
- **[CHALLENGES](./CHALLENGES.md)**: Price Trackers, Image Downloaders.

---

## 🔑 Key Concepts

| Library | Use Case |
| :--- | :--- |
| **`requests`** | Fetch the raw HTML. |
| **`BeautifulSoup`** | Parse the HTML tree/DOM. |
| **`lxml`** | Faster parser backend for BS4. |
| **`Selenium`** | Needed if the site requires JavaScript to render (Advanced). |

---

## 🏗️ Robust Parsing

### 1. User Agents
Some sites block scripts. Pretend to be a browser.

```python
headers = {'User-Agent': 'Mozilla/5.0'}
requests.get(url, headers=headers)
```

### 2. ID vs Class
IDs are unique (`#main`), Classes are not (`.product`). Prefer IDs for stability.

---

## 📖 Real-World Story: The "Silent White Screen"

**Problem**: The Load Balancer reported "Healthy" (200 OK), but the React App was crashing and displaying a blank white page.
**Solution**: A Python script scraped the page looking for the text "Copyright 2024".
**Result**: If the text was missing (blank page), the script alerted the team.

---

## ❓ Interview Questions

1.  **When to use Selenium vs BeautifulSoup?**
    - *Answer*: Use BS4 for static HTML (fast). Use Selenium for Single Page Apps (React/Vue) where content is rendered by JS.
2.  **Is scraping legal?**
    - *Answer*: Generally yes for public data, but respect `robots.txt` and Terms of Service. Don't DDoS the site.
3.  **What is `find()` vs `find_all()`?**
    - *Answer*: `find` returns the first match. `find_all` returns a list.

---

[Next: Data Processing Pandas](../13-Data-Processing-with-Pandas/README.md)
