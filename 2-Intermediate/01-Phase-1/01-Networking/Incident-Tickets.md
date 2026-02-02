# 🎫 Scenario-Based Labs: The Ticket Queue

> **"Theory is good. Fixing a P1 outage while the CEO is watching is better."**

## 📚 Overview
Instead of following a tutorial, you will solve **Incident Tickets**. These scenarios mimic real-world outages. Your goal is to determine the **Root Cause** using the tools in your toolbelt.

---

## 🎟️ Ticket #101: "App A can't talk to Redis"

**Severity:** High
**Status:** Open
**Description:**
> "We just deployed the new `service-user` to the Private Subnet. It's crashing on startup with `Connection Refused` when trying to reach the `redis-cluster` (10.0.3.50) on port 6379."

### 🕵️‍♂️ Your Mission (Investigation Steps)
1.  **Validate Connectivity:**
    *   Run: `nc -zv 10.0.3.50 6379`
    *   *Observation:* If it hangs, it's a **DROP** (Firewall/Security Group). If it says "Refused", the packet reached the server but was rejected (Service down or local firewall).
2.  **Check Security Groups (The Usual Suspect):**
    *   Does the Redis Security Group allow Inbound TCP 6379 from the **App Server's Security Group ID**?
    *   *Pro-Tip:* Never allow `0.0.0.0/0` on a database port.
3.  **Check Routing:**
    *   Are they in the same VPC? If not, is the Peering Connection active and the Route Table updated?

---

## 🎟️ Ticket #102: "Web traffic is slow from Asia"

**Severity:** Medium
**Status:** Open
**Description:**
> "Marketing is complaining that the landing page takes 5 seconds to load for users in Tokyo. US users see it in 200ms. The server is in `us-east-1`."

### 🕵️‍♂️ Your Mission (Investigation Steps)
1.  **Trace the Path:**
    *   Run: `mtr -rwc 10 <server-ip>` from a jumpbox in Asia.
    *   *Observation:* Look at the latency column. Does it jump from 20ms to 200ms at a specific hop (crossing the ocean)?
2.  **Analyze the Bottleneck:**
    *   If the latency is high due to physics (distance), you cannot "fix" the network.
    *   *Solution:* You need **Architecture** changes. Suggest implementing **CloudFront (CDN)** or **Route53 Latency-Based Routing** to serve content from a Tokyo region.

---

## 🎟️ Ticket #103: "The Hanging Curl"

**Severity:** Low (Internal Tool)
**Status:** Open
**Description:**
> "I can `ping` the internal API server over the VPN, but when I try to `curl` a large JSON payload, it just hangs forever at `TLS Handshake`."

### 🕵️‍♂️ Your Mission (Investigation Steps)
1.  **Identify the MTU Mismatch:**
    *   VPNs add headers to packets, reducing the available payload space (MSS). If a server sends a full 1500-byte packet, the VPN drops it because it's too big with the extra headers.
2.  **The Test:**
    *   Run: `ping -M do -s 1472 <host>` (Linux) or `ping -f -l 1472 <host>` (Windows).
    *   *Observation:* If you see "Packet needs to be fragmented but DF set", your MTU is too high.
3.  **The Fix:**
    *   Enable **TCP MSS Clamping** on the VPN router to automatically shrink the TCP segment size to fit inside the tunnel.

---

## 📝 Submission

For each ticket, write a **Post-Mortem** in your notes:
1.  **Root Cause:** What exactly was broken?
2.  **Detection:** Which command revealed the truth?
3.  **Fix:** What configuration change solved it?
4.  **Prevention:** How do we stop this from happening again? (e.g., "Add Terraform validation for Security Groups").

> [!IMPORTANT]
> **Senior SRE Note:** "I don't care that you fixed it. I care that you understand *why* it broke so I don't have to fix it next week."
