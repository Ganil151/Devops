# 🧪 Networking Diagnostic Lab

> **"Theory is when you know everything but nothing works. Practice is when everything works but no one knows why. In this lab, we hunt for the 'Why'."**

In this lab, you will act as the "Net-SRE" on call. You have three scenarios to solve using only the CLI.

---

## 🚩 Scenario 1: The Invisible Server
**Problem**: You can't reach `http://webapp.internal`.
**Goal**: Use `ping` and `dig` to find out if the server is down or if your DNS is lying to you.

## 🚩 Scenario 2: The Blocked Port
**Problem**: The database is running, but your app says "Connection Refused."
**Goal**: Use `nc -zv <db-ip> 5432` or `telnet` to see if a firewall is blocking the handshake.

## 🚩 Scenario 3: The Slow Route
**Problem**: Traffic from your office to the cloud provider is takes 2 seconds vs. 20ms.
**Goal**: Use `mtr` to identify which specific router (hop) is causing the delay.

---

## 🛠️ Tool Cheat Sheet
- `ip a`: Check your own IP.
- `netstat -tulpn`: See what's listening on your own server.
- `tcpdump`: The nuclear option. Listen to the raw bits on the wire.

---
*Success Metric: Solve all three scenarios without restarting the server.*
