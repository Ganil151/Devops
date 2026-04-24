# Log Analysis and Parsing

Automation isn't just about changing systems; it's about making sense of the mountains of data they produce.

## 📚 Module Structure
- **[Boilerplates](readme.md)**: `analyze_logs.sh` (Top IPs and Errors).
- **[CHALLENGES](./challenges.md)**: Building custom dashboards from raw text.

---

## 🏗️ Scenario: The "Needle in the Haystack"
**Problem**: An application logs 100MB of data every hour. A user reports a failure at 2:00 PM.
**Solution**: Use Bash pipeline to narrow down the search.

```bash
grep "2024-01-15 14:" /var/log/app.log | grep "ERROR" | tail -n 20
```

---

## 🏗️ Scenario: The "Top 10" Reporter
**Problem**: Identify the most common error codes.
**Solution**:
```bash
awk '{print $9}' access.log | sort | uniq -c | sort -nr | head -n 10
```

---

## 📖 Real-World Story: The "DDoS Detection"
A sysadmin noticed high CPU on a web server. They ran a one-liner to see the Top 5 IP addresses hitting the site. They found one IP hitting the site 500 times per second. 
**Action**: Blocked the IP via firewall. 
**Result**: CPU returned to normal in 10 seconds.

---

## ❓ Interview Questions
1. **Explain the difference between `uniq` and `sort | uniq`.**
   - *Answer*: `uniq` only removes *adjacent* duplicate lines. `sort` ensures all duplicates are adjacent so `uniq` can catch them all.
2. **How do you print the 5th column of a log file using `awk`?**
   - *Answer*: `awk '{print $5}'`.

---

[Next: Cloud Governance](../03-cloud-governance-and-costs/readme.md)
