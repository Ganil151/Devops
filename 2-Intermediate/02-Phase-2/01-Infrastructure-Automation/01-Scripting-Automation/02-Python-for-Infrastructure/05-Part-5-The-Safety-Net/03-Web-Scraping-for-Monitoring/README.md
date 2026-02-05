# 🕸️ Web Scraping: The Monitoring of Last Resort

> **"An API is a promise. A webpage is reality. When the promise fails, or was never made, scraping is the only way to verify the user experience."**

Welcome to the **Web Scraping & Synthetic Monitoring** module. In the DevOps world, we use scraping not just to "steal data," but to perform **Blackbox Monitoring**. If a legacy dashboard has no API, or you need to verify that your React app actually "renders" text on the screen (rather than just returning a 200 OK blank page), Python is your primary tool.

**Why This Matters for Junior DevOps Engineers:**
- 🛡️ **Blackbox Testing**: Verifying the site works from the *outside*.
- ⚡ **Legacy Integration**: Extracting status metrics from a 1999 router web interface.
- 🎯 **Interview**: "How do you monitor a page that renders via JavaScript?"
- 🔧 **End-to-End**: Logging in, clicking buttons, and verifying checkout flow automatically.

---

## 📚 Table of Contents

1. [Architecture: Static vs Dynamic Scraping](#-architecture-static-vs-dynamic-scraping)
2. [The Static Scraper (BeautifulSoup)](#-the-static-scraper-beautifulsoup)
3. [The Dynamic Scraper (Playwright)](#-the-dynamic-scraper-playwright)
4. [Real-World DevOps Scenarios](#-real-world-devops-scenarios)
5. [Security Best Practices](#-security-best-practices)
6. [Common Pitfalls & Solutions](#-common-pitfalls--solutions)
7. [Hands-On Exercises](#-hands-on-exercises)
8. [Interview Preparation](#-interview-preparation)
9. [Knowledge Check](#-knowledge-check)

---

## 🏗️ Architecture: Static vs Dynamic Scraping

Not all websites are HTML.

```mermaid
graph TD
    A[Monitor Script] --> B{Content Type?}
    B -- Static HTML --> C[Requests + BeautifulSoup]
    B -- SPA / React --> D[Headless Browser (Playwright)]
    C --> E[Fast, Lightweight]
    D --> F[Executes JS, Heavy]
    E & F --> G[Extract Metric]
    G --> H[Prometheus / Alert]
    
    style C fill:#fef3c7,stroke:#d97706
    style D fill:#f0fdf4,stroke:#15803d
```

### 🔍 Concept Breakdown
1.  **Static**: Server sends full HTML. (Requests/BS4).
2.  **Dynamic**: Server sends JS. Browser renders HTML. (Playwright/Selenium).
3.  **Headless**: A browser with no GUI for server-side execution.

---

## 🥣 The Static Scraper (BeautifulSoup)

Best for: Simple checks, Status pages, XML/RSS feeds.

```python
import requests
from bs4 import BeautifulSoup
import sys

def check_version(url):
    # 🎭 Masquerade as a real browser
    headers = {'User-Agent': 'Mozilla/5.0 (DevOps Monitor)'}
    
    try:
        resp = requests.get(url, headers=headers, timeout=5)
        resp.raise_for_status()
        
        soup = BeautifulSoup(resp.text, 'html.parser')
        
        # 🔍 Find element by ID
        version_div = soup.find(id="app-version")
        
        if not version_div:
            print("❌ Version not found in DOM!")
            sys.exit(1)
            
        print(f"✅ Version detected: {version_div.text.strip()}")
        
    except Exception as e:
        print(f"🔥 Scraping failed: {e}")
```

---

## 🎭 The Dynamic Scraper (Playwright)

Best for: React/Vue/Angular Apps, Login forms, Screenshots.

```python
from playwright.sync_api import sync_playwright

def login_check():
    with sync_playwright() as p:
        # Launch headless Chrome
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        
        # 🚀 Navigate
        page.goto('https://myapp.internal/login')
        
        # ⌨️ Interact
        page.fill('input[name="user"]', 'admin')
        page.fill('input[name="password"]', 'secret')
        page.click('button[type="submit"]')
        
        # ⏳ Wait for React to render dashboard
        page.wait_for_selector('#dashboard-welcome')
        
        # 📸 Evidence
        page.screenshot(path='success.png')
        print("✅ Login Flow Successful")
        
        browser.close()
```

---

## 🎭 Real-World DevOps Scenarios

### 🧱 Scenario 1: The "200 OK" White Screen

**The Incident:** The Load Balancer health check passed (200 OK), but the React app crashed on load (Blank White Screen).
**The Failure:** Standard monitoring only checked HTTP Status, not content.
**The Fix:** A **Synthetics** check using Playwright that waits for the "Add to Cart" button to actually appear on the screen.

### 🔥 Scenario 2: Legacy Router Scraping

**The Task:** Monitor the CPU Temperature of a 15-year-old Switch that has no SNMP and no API.
**Solution:** Requests + BS4.
1. Script logs into the web interface.
2. Navigates to `/status.html`.
3. Regexes the valid temperature string (`Temp: 45C`).
4. Pushes metric to Prometheus Gateway.

### ☁️ Scenario 3: Cloudflare Challenge

**The Problem:** Your script gets `403 Forbidden` because the site thinks you are a bot.
**Solution:**
1. Use real User-Agent headers.
2. Use **Playwright** (passes JS challenges).
3. Rate limit your requests (sleep 5s between calls).

---

## 🔒 Security Best Practices

### 1. User-Agent
Always identify your bot (internally) or mimic a browser (externally).
`User-Agent: Internal-Uptime-Bot/1.0`

### 2. Timeouts
Never scrape without a timeout.
`requests.get(timeout=10)`
Without this, your monitoring script hangs forever if the target server hangs.

### 3. Rate Limiting
Don't DDoS your own infrastructure. Put `time.sleep(1)` inside loops.

---

## ⚠️ Common Pitfalls

### Pitfall 1: Relying on CSS Classes
**Bad**: `soup.select('.btn-blue-large')`
**Why**: Developers change CSS often.
**Good**: `soup.select('#login-button')` (IDs are stable) or `soup.find(text="Login")`.

### Pitfall 2: Ignoring Robots.txt
**Issue**: Scraping disallowed paths.
**Fix**: Check `site.com/robots.txt` before scraping public sites.

---

## 🎯 Hands-On Exercises

### Exercise 1: The News Scraper (BS4)
**Objective**: Scrape a news site.
**Requirements**:
1. Fetch `news.ycombinator.com`.
2. Extract the titles of the top 3 stories.
3. Print them.

### Exercise 2: The Screenshot Bot (Playwright)
**Objective**: Visual Verification.
**Requirements**:
1. Go to `google.com`.
2. Type "DevOps" in the search bar.
3. Take a screenshot `result.png`.

---

## 🎙️ Interview Preparation

### Foundation Questions

**1. "Difference between BeautifulSoup and Selenium?"**
- **Answer**: BS4 parses static HTML text (fast). Selenium/Playwright drives a real browser engine to execute JavaScript (slow but accurate for SPAs).

**2. "What is Headless Mode?"**
- **Answer**: Running a browser without a GUI window. Essential for running UI tests on Linux servers (CI/CD pipelines).

### Advanced Scenario Questions

**3. "How do you monitor a metric that is only available on a webpage behind a login?"**
- **Answer**:
    1. Script POSTs credentials to `/login`.
    2. Saves the `Session` cookie.
    3. Uses that cookie to request the dashboard page.
    4. Parses the metric.

---

## 🧠 Knowledge Check

**1. Which library executes JavaScript?**
- [ ] `requests`
- [ ] `BeautifulSoup`
- [x] `Playwright`

**2. What identifies your script to the server?**
- [ ] `Accept` header
- [x] `User-Agent` header
- [ ] `Cookie` header

**3. Why use `id` selectors over `class` selectors?**
- [ ] They are faster.
- [x] They are unique and less likely to change during re-styling.
- [ ] They are encrypted.

---

## 🎓 Self-Assessment Checklist

Before moving to the next module, ensure you can:
- [ ] Perform a GET request with Custom Headers.
- [ ] Parse HTML using `BeautifulSoup`.
- [ ] Explain when to use Playwright vs Requests.
- [ ] Implement a Retry loop for flaky sites.

**Score yourself**: 5+/5 = Ready to advance | <5 = Review exercises

[⬅️ Back to Docker SDK](README.md) | [Next: Pandas](README.md) ➡️
