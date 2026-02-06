# 🌐 Advanced DNS & Diagnostics

> **"Junior, 90% of the time, it's DNS. The other 10% is usually also DNS, but with a caching TTL of 0. Let's learn how to prove it's DNS so the developers stop blaming the firewall."**

---

## 🏗️ The Junior NRE Briefing

**Subject**: Domain Name System (DNS) & DHCP
**The Problem**: Apps don't speak IP; they speak Hostnames. When `api.backend.local` fails to resolve, your entire microservices architecture halts.

**Terminology Upgrade**:
*   **Resolution**: The act of turning a name into an IP.
*   **Propagation**: The time it takes for a DNS record change to travel across the globe.
*   **TTL (Time To Live)**: How long a resolver *remembers* an answer before asking again.
*   **Recursive Query**: "Go find the answer for me." (Client -> Resolver).
*   **Iterative Query**: "Tell me who knows the answer." (Resolver -> Root -> TLD).

---

## 🛠️ The NRE Toolkit: Debugging DNS

Stop using `ping` to test DNS. Use tools designed for the job.

### 1. `dig` (Domain Information Groper)
The industry standard for DNS troubleshooting.

```bash
# Basic Lookup
dig google.com

# Trace the entire hierarchy (Root -> Com -> Google)
# PRO TIP: Use this to see *exactly* where a resolution fails.
dig +trace google.com

# Query a specific server (Bypass your local cache)
dig google.com @8.8.8.8
```

### 2. `nslookup` (Interactive Mode)
Good for Windows/Cross-platform checks.

```bash
nslookup
> server 8.8.8.8    # Set specific server
> set type=MX       # Look for Mail Records
> google.com
```

---

## 🏗️ Technical Deep Dive: Production DNS

### The "Split-Horizon" Pattern
In production (AWS/Corporate), accessing `jira.company.com` should return:
*   **10.5.1.20** (Private IP) if you are inside the VPN.
*   **54.12.33.44** (Public IP) if you are at Starbucks.

This is called **Split-Horizon DNS**.
*   **Internal Resolver**: AWS Route53 (Inbound Endpoint).
*   **External Resolver**: Public DNS zone.

### The K8s Effect (CoreDNS)
Inside Kubernetes, `app-a` talks to `app-b` using names like `app-b.default.svc.cluster.local`.
This is handled by **CoreDNS**. If this pod crashes, internal networking dies, even if the physical network is fine.

---

## 🎫 Junior's First Ticket: "The App Can't Connect"

**Scenario**: A developer says their Python app is crashing with `socket.gaierror: [Errno -2] Name or service not known`.

**Your Mission**: Troubleshoot the failure.

**The Flowchart**:
1.  **Check Local Config**:
    ```bash
    cat /etc/resolv.conf
    # Look for 'nameserver'. In AWS, it's usually the VPC base + .2 (e.g., 10.0.0.2)
    ```
2.  **Test Resolution**:
    ```bash
    dig db-prod.internal.local
    # If Status: NXDOMAIN -> The name does not exist. Typo?
    # If Status: SERVFAIL -> The DNS server is crashed or unreachable.
    ```
3.  **Check Connectivity to DNS Server**:
    ```bash
    # DNS uses UDP port 53. Telnet won't work. Use Netcat (nc).
    nc -zv -u 10.0.0.2 53
    ```

**Root Cause Revealed**: The developer typed `db-prod.interal.local` (Typo). NRE saves the day.

---

## 🛡️ DNS Security Extensions (DNSSEC)

Standard DNS is unencrypted UDP. It can be spoofed (Man-in-the-Middle).
*   **DNSSEC**: Signs the records cryptographically.
*   **The Chain of Trust**: The Root signs the TLD (.com), the TLD signs the Domain.

---

## 📝 Knowledge Check

1.  **Which command traces the full path of a DNS query from Root to Authority?**
    *   `ping -a`
    *   `dig +trace`
    *   `traceroute`

2.  **What does a TTL of 300 mean?**
    *   The record is cached for 300 seconds (5 minutes).
    *   The record takes 300ms to resolve.

3.  **Why does `telnet google.com 53` fail?**
    *   DNS uses UDP by default; Telnet speaks TCP.

4.  **If `dig` returns `NXDOMAIN`, what is the most likely issue?**
    *   The domain name does not exist (or is typed wrong).

---

## 🔗 Next Steps

DNS tells us *where* to go. Now let's see *how* the network is sliced up to get there.

Proceed to: **[Subnetting & CIDR](../02-subnetting-and-cidr/readme.md)** →