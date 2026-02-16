# 🛠️ Real-Life Networking Scenarios for DevOps

Understanding the OSI model isn't just for exams—it's the framework for troubleshooting production issues. Here are common scenarios mapped to the layers.

## Scenario 1: "The Application is Slow"
**User Complaint:** "The website takes 10 seconds to load."

**DevOps Analysis using OSI:**
1.  **Layer 1 (Physical)**: Is the server network cable plugged in? (Usually handled by cloud provider). Is bandwidth saturated?
2.  **Layer 3 (Network)**: Check latency. Run `ping` or `traceroute`. Are packets taking a bad route across the internet?
3.  **Layer 4 (Transport)**: high retransmission rates? Is the TCP window scaling correctly?
4.  **Layer 7 (Application)**: *Most likely culprit.*
    - Is the database query slow?
    - Is the code unoptimized?
    - Check Nginx/Apache logs for processing time vs. upstream time.

**Resolution:** Found that a database query was unindexed (Layer 7 logic), causing the app to wait.

---

## Scenario 2: "Connection Refused"
**User Complaint:** "I can't connect to the database via the terminal."
`psql: could not connect to server: Connection refused`

**DevOps Analysis:**
1.  **Layer 3 (Network)**: Can I `ping` the database server?
    - If YES: Routing and IP are fine.
    - If NO: Check Route Tables and VPC Peering.
2.  **Layer 4 (Transport)**: Is the port (5432) open?
    - Check **Security Groups** (AWS) or **Firewall Rules**.
    - Run `telnet <db-ip> 5432` or `nc -vz <db-ip> 5432`.
    - If `telnet` fails, it's a firewall (Layer 4) issue.
    - If `telnet` connects but app fails, it's app config.

**Resolution:** The Security Group for the Database only allowed the Jump Host IP, but I was connecting from my laptop (Layer 4).

---

## Scenario 3: "502 Bad Gateway"
**User Complaint:** "The site is down, showing a 502 error."

**DevOps Analysis:**
1.  **Layer 7 (Application)**: A 502 means the *Load Balancer* (Gateway) got an invalid response from the *Backend Server*.
    - The Load Balancer talks Layer 7 (HTTP) to the backend.
    - Check the Backend Server logs. Is the application service running?
    - Is the backend crashing on startup?

**Resolution:** The Node.js application process had crashed `OOM` (Out of Memory). Restarts fixed it (Layer 7).

---

## Scenario 4: "DNS Resolution Failed"
**User Complaint:** "My deployment script fails with `Could not resolve host: github.com`."

**DevOps Analysis:**
1.  **Layer 3 (Network)**: Does the server have internet access?
    - Can it ping `8.8.8.8`? (Google DNS IP).
    - If YES: Internet routing is fine.
    - If NO: Check NAT Gateway or Internet Gateway.
2.  **Layer 7 (Application)**: If it can ping IP but not Name, it's DNS.
    - Check `/etc/resolv.conf`.
    - Is port 53 (UDP/TCP) blocked outbound?

**Resolution:** The VPC DHCP options set were pointing to a DNS server that was decommissioned. Updated to use Cloud Provider DNS.

---

## 🎨 Visualization: The "Troubleshooting Stack"

When things break, start from the bottom (Physical) or specific layers based on the error:

| Error Type | Likely Layer | Tool to Check |
| :--- | :--- | :--- |
| "No route to host" | Layer 3 (Network) | `ip route`, `traceroute` |
| "Connection Timed Out" | Layer 4 (Transport/Firewall) | Security Groups, `telnet` |
| "Connection Refused" | Layer 4 (Service Down) | `systemctl status`, `netstat` |
| "500/502/404 Error" | Layer 7 (Application) | App Logs, Nginx Logs |
| "Name not resolved" | Layer 7 (DNS) | `nslookup`, `dig` |
