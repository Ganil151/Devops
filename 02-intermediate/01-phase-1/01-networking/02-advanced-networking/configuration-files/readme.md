# 📂 NRE Configuration Vault: production_ready = true

> **"Junior, configs are code. A single typo in a timeout value can bring down a billion-dollar platform. We don't guess values. We calculate them."**

---

## 🏗️ The Archive

| File | Purpose | The "Pro" Difference |
| :--- | :--- | :--- |
| **[nginx-production-gateway.conf](./nginx-production-gateway.conf)** | Layer 7 Reverse Proxy | Handles `X-Forwarded-For`, Timeouts, and Keepalives. |
| **[sysctl-high-throughput.conf](./sysctl-high-throughput.conf)** | Linux Kernel Tuning | Optimizes `TCP` stack for 10k+ concurrent connections. |
| **[keepalived-ha.conf](./keepalived-ha.conf)** | Floating IP (VRRP) | High Availability for Bare Metal / Non-Cloud setups. |

---

## ⚠️ The "Silent Killers" of Configuration

### 1. The Default Timeout Trap
**Scenario**: You use default Nginx `proxy_read_timeout` (60s).
**The Crash**: Your backend app hangs. The user waits 60 seconds of "Loading..." before seeing an error.
**The Fix**: Fail Fast. Set aggressive timeouts (e.g., 5s) for user-facing APIs.

### 2. The Logic of Backlogs
**Scenario**: You have 16GB RAM but your server rejects connections at 128 users.
**The Reason**: `net.core.somaxconn` defaults to 128 in many distros.
**The Fix**: Tune the kernel `sysctl` to allow a listen queue of 4096+.

---

## 📄 Usage Instructions

1.  **Don't just copy-paste.** Read the comments.
2.  **Validate syntax**:
    *   Nginx: `nginx -t`
    *   Sysctl: `sysctl -p --system`
3.  **Benchmark**: Use `ab` (Apache Bench) or `k6` to prove your config handles load BETTER than the default.

> **"A config file without comments is technical debt."**
