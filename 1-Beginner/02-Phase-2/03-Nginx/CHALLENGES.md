# 🏗️ Nginx Implementation Challenges

> **"Configuration is the theory; implementation is the practice. Build your own high-availability edge layer."**

## 🏁 Introduction
These 10 challenges follow a progressive learning path. You will start with basic hosting and end by building a secure, load-balanced, cached production environment.

---

## 🟢 Level 1: Beginner (The Server)

### Challenge 1: The Static Host
**Objective**: Serve a custom HTML website.
- **Task**: Modify the default Nginx configuration to serve files from `/var/www/mywebsite` instead of the default directory.
- **Success Criteria**: Opening `localhost` shows your custom index page.

### Challenge 2: The Proxy Bridge
**Objective**: Mask a backend service.
- **Task**: Start a simple web app (using Python's `http.server` or a Node.js script) on port 8000. Configure Nginx to forward traffic from `http://localhost/app` to that service.
- **Success Criteria**: Accessing the root of Nginx returns the output of your Python/Node server.

---

## 🟡 Level 2: Intermediate (The Orchestrator)

### Challenge 3: Round Robin Army
**Objective**: Build a simple Load Balancer.
- **Task**: Start three separate backend servers on ports 8001, 8002, and 8003. Configure Nginx to balance traffic across them using Round Robin.
- **Success Criteria**: Refreshing the Nginx page rotates the response between the three servers.

### Challenge 4: Weighting the Power
**Objective**: Favor a stronger server.
- **Task**: Use the setup from Challenge 3, but give the server on port 8001 a **Weight of 3**.
- **Success Criteria**: You receive the response from Server 8001 three times as often as the others.

### Challenge 5: Context Routing
**Objective**: Multi-service architecture.
- **Task**: Configure Nginx such that:
    - `/` serves static HTML.
    - `/api` proxies to a backend on port 9000.
    - `/admin` proxies to a backend on port 9001.
- **Success Criteria**: Each URL path hits the correct distinct backend.

---

## 🔴 Level 3: Advanced (The Hardened Edge)

### Challenge 6: The SSL Lock
**Objective**: Secure your traffic.
- **Task**: Use a self-signed certificate (or Certbot in staging mode) to enable HTTPS on port 443. Force all Port 80 traffic to redirect to 443.
- **Success Criteria**: Accessing `http://localhost` automatically changes the URL to `https://localhost`.

### Challenge 7: The Gzip Squeeze
**Objective**: Bandwidth optimization.
- **Task**: Enable Gzip compression. Verify it is working by checking the response headers for `Content-Encoding: gzip`.
- **Success Criteria**: Browsing a large text file shows a reduced transferred size in the Network tab.

### Challenge 8: The 1-Second Mirror (Micro-Caching)
**Objective**: Handle high-traffic dynamic data.
- **Task**: Configure Nginx to cache responses from a dynamic backend for exactly **1 second**.
- **Success Criteria**: If you update the backend data and refresh quickly, you still see the old data for 1 second before it updates.

### Challenge 9: Custom Error Branding
**Objective**: Professional Error Pages.
- **Task**: Design a custom `404.html` and `50x.html` page. Configure Nginx to show these instead of the generic white screen.
- **Success Criteria**: Navigating to a non-existent URL shows your custom branded 404 page.

---

## 🏆 Final Boss: The Scalable Fortress
**The Scenario**: You are deploying a global news site.
- **The Task**: Implement an Nginx config that:
    1. Balances traffic between 2 servers.
    2. Redirects all traffic to HTTPS.
    3. Caches images for 30 minutes.
    4. Caches the API feed for 5 seconds.
    5. Hides the Nginx version number from headers.
- **Success Criteria**: A single configuration file that passes `nginx -t` and satisfies all security/performance requirements.

---

## 📖 Guidance & Snippets

### Solution 7: Gzip Check
```bash
curl -I -H "Accept-Encoding: gzip" http://localhost
# Look for 'Content-Encoding: gzip'
```

### Solution 10: Server Tokens
```nginx
http {
    server_tokens off;
}
```

---

## 🔗 Next Steps

Mastered the Edge? Let's move deeper into the build pipeline!

Proceed to: **[Maven and Build Tools](../../../README.md)** →
