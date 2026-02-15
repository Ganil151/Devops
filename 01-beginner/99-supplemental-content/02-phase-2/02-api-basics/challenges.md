# 🎯 API Discovery Challenges

> **"Theory explains the protocol; challenges explain the reality. Build, break, and debug your way to API mastery."**

## 🏁 Introduction
These challenges are designed to take you from a curious observer to a surgical API debugger. You will use **cURL**, **Postman**, and **Browser DevTools** to interact with real-world public APIs.

---

## 🟢 Level 1: Beginner (The Observer)

### Challenge 1: The HTTP Handshake
**Objective**: Interrogate a server and see the hidden "conversations" (headers).
- **Task**: Use cURL to fetch the headers of `https://google.com`.
- **Requirements**:
    - Use the `-I` flag to get only headers.
    - Identify the `Server` header and the `Content-Type`.
- **Success Criteria**: You can name the server software Google uses.

### Challenge 2: The Status Code Hunt
**Objective**: Trigger different status codes.
- **Task**: Find URLs on a test site (or use `https://httpstat.us/`) that return:
    - `200` (Success)
    - `404` (Not Found)
    - `503` (Service Unavailable)
- **Success Criteria**: You have a cURL command for each code.

---

## 🟡 Level 2: Intermediate (The Integrator)

### Challenge 3: Public API Authentication
**Objective**: Use an API Key to fetch data.
- **Task**: Sign up for a free API (like OpenWeatherMap or Dog-API) and fetch a piece of data using an `Authorization` header or query param.
- **Success Criteria**: A JSON response containing real-world data.

### Challenge 4: The JSON Surgeon
**Objective**: Filter API responses on the command line.
- **Task**: Fetch a list of public repositories from the GitHub API (`https://api.github.com/users/<username>/repos`) and use `jq` to print ONLY the names of the repositories.
- **Success Criteria**: A clean list of repo names without any JSON braces or quotes.

---

## 🔴 Level 3: Advanced (The Defender)

### Challenge 5: Implementing Backoff
**Objective**: Build a resilient script.
- **Task**: Write a small bash script that calls an API. If it receives a `429` error, the script must wait and retry.
- **Hint**: Use a `while` loop and sleep.
- **Success Criteria**: The script successfully handles a simulated rate limit.

### Challenge 6: Webhook Simulation
**Objective**: Understand the "Push" model.
- **Task**: Use a tool like **Webhook.site** to create a unique URL. Use cURL to POST a JSON payload to that URL and watch it appear in the dashboard.
- **Success Criteria**: You can see your custom JSON body in the webhook inspector.

---

## 🏆 Final Boss: The "Idempotent" Deployment
**The Scenario**: You are writing a script that triggers a server deployment. The API is flakey. 
- **The Task**: You must write a script that sends a unique `X-Deployment-ID` header. You must retry the request 3 times if it fails.
- **The Goal**: Ensure that no matter how many times the script retries, the server only triggers **one** deployment.
- **Success Criteria**: A script that logs "Deployment successful" even if it failed twice before succeeding.

---

## 📖 Solutions & Guidance

### Solution 1: Headers
```bash
curl -I https://google.com
# Look for 'Server: gws'
```

### Solution 4: JQ Filtering
```bash
curl -s https://api.github.com/users/octocat/repos | jq -r '.[].name'
```

---

## 🔗 Next Steps

Mastered the challenges? Let's look at the backbone of these APIs!

Proceed to: **[01-HTTP-Protocol](readme.md)** →
