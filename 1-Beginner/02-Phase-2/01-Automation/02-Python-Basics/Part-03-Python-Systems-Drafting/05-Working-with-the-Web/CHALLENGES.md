# 🎯 Working with the Web - Challenges

> **"An API is a promise. These challenges test your ability to hold systems to that promise by fetching, validating, and orhcestrating data over the wire."**

---

## 🏆 Challenge 1: The Status Auditor
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 15 minutes

### Objective
Create a script that checks a list of public URLs and reports their status.

### Requirements
- Define a list of 5 URLs (e.g., GitHub, Google, a non-existent site).
- Use `requests.get()` with a `timeout=3`.
- Print a clean report: `[200 OK] https://github.com` or `[404 FAIL] https://...`.
- Handle `ConnectionError` gracefully without crashing.

### Hints
- Use a `for` loop to iterate through the list.
- Use `response.status_code`.

---

## 🏆 Challenge 2: The GitHub Repo Finder
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 30 minutes

### Objective
Query the GitHub API to find the top 5 most starred Python repositories.

### Requirements
- Target: `https://api.github.com/search/repositories?q=language:python&sort=stars&order=desc`.
- Extract the `name`, `stargazers_count`, and `html_url`.
- Print the results in a formatted table.
- **Fail-Safe**: Check `response.status_code` before parsing.

### Hints
- Use `response.json()` to parse the data.
- The items are inside a list called `items` in the JSON response.

---

## 🏆 Challenge 3: The Secret Vault (Secure Auth)
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 45 minutes

### Objective
Build a script that interacts with an authenticated API (e.g., GitHub User info or a mock API) using Bearer Tokens.

### Requirements
- Load an API Token from an Environment Variable (Do NOT hardcode).
- Send the token in an `Authorization: Bearer <token>` header.
- Fetch your own GitHub user profile data (`GET https://api.github.com/user`).
- Display your username, public repo count, and bio.
- Handle 401 Unauthorized errors with a helpful message: "Check your token!"

### Hints
- Use `os.getenv("GITHUB_TOKEN")`.
- Use `headers={"Authorization": f"Bearer {token}"}`.

---

## 🎓 Bonus Challenge: The Scraper of Last Resort
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 60 minutes

### Objective
Extract the "Current Temperature" from a weather website that doesn't have a simple API.

### Requirements
- Use `requests` to fetch the HTML.
- Use `BeautifulSoup` to find the specific element (by ID or Class).
- Extract only the numeric temperature value.
- Log an error if the element cannot be found (e.g., site structure changed).

---

## ✅ Completion Checklist
- [ ] Challenge 1: Status Auditor
- [ ] Challenge 2: GitHub Repo Finder
- [ ] Challenge 3: Secret Vault
- [ ] Bonus: Scraper of Last Resort
