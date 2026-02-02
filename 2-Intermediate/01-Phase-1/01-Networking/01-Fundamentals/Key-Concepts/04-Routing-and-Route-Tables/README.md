# 🚦 Routing & Route Tables: The Traffic Control

> **"Junior, a router doesn't 'think'. It calculates. If you understand the algorithm (Longest Prefix Match), you can predict exactly where a packet will go. If you guess, you cause outages."**

---

## 🏗️ The Junior NRE Briefing

**Subject**: Route Tables & BGP
**The Problem**: A packet arrives at the router. It has destination `10.0.1.50`. The router has 100 paths. Which one does it pick?
**The Golden Rule**: **Longest Prefix Match (LPM)**. The most specific route wins.

**Terminology Upgrade**:
*   **Propagation Check**: "Did the route arrive?" vs "Is the route active?"
*   **Blackhole**: A route exists, but the target (NAT Gateway, Peering Connection) is dead or deleted.
*   **0.0.0.0/0**: The "Gateway of Last Resort" (The Internet).

---

## 📐 The Algorithm: Longest Prefix Match (LPM)

Every NRE interview asks this.

**Scenario**: A packet is headed to `10.0.1.50`.
The Route Table has these entries:

1.  `10.0.0.0/16` -> Local (VPC)
2.  `10.0.1.0/24` -> Peering Connection A
3.  `0.0.0.0/0`   -> Internet Gateway

**Who wins?**
*   `/24` is "longer" (more specific) than `/16`.
*   `/16` is "longer" than `/0`.
*   **Winner**: Route #2. The packet goes to Peering Connection A.

**NRE Tip**: Security appliances often use minimal specific routes (like `/32`) to "hijack" traffic for inspection, overriding the standard `/16` local flow.

---

## 🎫 Junior's First Ticket: "The Blackhole Mystery"

**Scenario**: The Data Science team says they can't reach the Legacy Database in the old VPC.
**Observation**: The connection times out. No "Refused", just silence.

**Your Mission**: Trace the path.

**The NRE Workflow**:
1.  **Check the Route Table**:
    ```bash
    aws ec2 describe-route-tables --route-table-id rtb-prod-app
    ```
2.  **Analyze the Output**:
    ```json
    {
        "DestinationCidrBlock": "172.16.0.0/16",
        "GatewayId": "pcx-12345678",
        "State": "blackhole"  <-- !!!
    }
    ```
3.  **The Diagnosis**: The `State: blackhole` means the Target (`pcx-12345678` - the Peering Connection) was deleted, but the Route wasn't. The router is throwing packets into the void.
4.  **The Fix**: Remove the stale route and create a new Peering Connection (or update the route to point to the new one).

---

## 🛠️ Debugging with `mtr`

Traceroute is old. `mtr` (My Traceroute) handles packet loss analysis.

```bash
# Run a report (-r) with 10 cycles (-c 10)
# Look for the last hop before it dies.
sudo mtr -r -c 10 172.16.50.5
```

If it stops at your VPC Router (Gateway), it's a Route Table issue.
If it stops at the destination VPC Router, it's a Security Group / NACL issue.

---

## 📝 Knowledge Check

1.  **Which route wins: `10.0.0.0/16` or `10.0.1.0/24`?**
    *   `/24` (Explicit/Specific beats Generic).

2.  **What does route state "Blackhole" mean?**
    *   The route destination is valid (CIDR), but the target gateway does not exist.

3.  **Can you have two identical routes to the same destination?**
    *   No. The Router won't allow duplicate destination CIDRs in the same table.

---

## 🔗 Next Steps

You can route packets, but can you prove they are safe?

Proceed to: **[Security Groups & NACLs](../../02-Advanced-Networking/README.md)** →
