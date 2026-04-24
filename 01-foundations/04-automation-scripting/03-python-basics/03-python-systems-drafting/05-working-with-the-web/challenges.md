# 🎯 Working with the Web: API & Orchestration Challenges

> **"Infrastructure is behind an API. These challenges test your ability to fetch, validate, and automate across the wire using professional HTTP patterns."**

---

## 🏆 Challenge 1: The Resilient Health Checker
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 20 minutes

### Objective
Build a status auditor that handles timeouts and connection errors like a production monitoring tool.

### Requirements
- Create a list of 5 URLs (include `http://httpstat.us/200`, `http://httpstat.us/404`, and `http://httpstat.us/500`).
- Use `requests.get()` with a **mandatory `timeout=5`**.
- Use **`response.raise_for_status()`** inside a `try/except` block.
- **Reporting**: Print `[OK]` for 200s, `[ERROR]` for 4xx/5xx, and `[TIMEOUT]` if the server is too slow.

---

## 🏆 Challenge 2: The GitHub Top-5 Automator
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 30 minutes

### Objective
Query the GitHub Search API and create a structured local backup of the results.

### Requirements
- URL: `https://api.github.com/search/repositories?q=language:python&sort=stars`
- Use a **`requests.Session()`** object for the request.
- Extract the top 5 results: `name`, `owner.login`, and `stargazers_count`.
- Save the results into a file named `top_python_repos.json` using the `json` module.
- **Pro Pattern**: Add a custom `User-Agent` header to your session to avoid being blocked by GitHub's rate limiter.

---

## 🏆 Challenge 3: The Secret Vault Orchestrator
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 45 minutes

### Objective
Authenticate against an API and perform a structured sequence of actions.

### Requirements
- Fetch an **API Token** from an environment variable `SERVICE_TOKEN`.
- Create a function `get_user_info(token)` that calls an API (e.g., GitHub `/user` or a mock service).
- If the response is `401 Unauthorized`, print a "Security Alert: Token Expired" message and exit.
- If successful, parse the JSON and print: "Authenticated as [username]. Account created on [date]".
- **Bonus**: Implement a simple **retry loop** (wait 2 seconds and try again) if you get a `503 Service Unavailable`.

---

## 🏆 Bonus: The "Legacy Miner" (BeautifulSoup)
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 60 minutes

### Objective
Extract structured data from a legacy HTML page.

### Requirements
- Use `requests` to fetch a page with a list of items (e.g., a news site or status page).
- Use `BeautifulSoup` to find all `<a>` tags or a specific `<table>` row.
- Filter the results to only show items containing the word "Security" or "CVE".
- **Documentation**: Write a comment explaining why this is a "last resort" compared to an API.

---

## ✅ Completion Checklist
- [ ] Challenge 1: Resilient Health Checker
- [ ] Challenge 2: GitHub Top-5 Automator
- [ ] Challenge 3: Vault Orchestrator
- [ ] Bonus: Legacy Miner (Scraping)
