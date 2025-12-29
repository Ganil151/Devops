# Monitoring Basics & The Four Golden Signals

Monitoring is the process of collecting, aggregating, and analyzing metrics to improve the awareness of your system's state.

---

## 🏗️ 1. The Four Golden Signals
If you can only monitor four things, monitor these (as defined by Google SRE):

1. **Latency**: The time it takes to service a request. It's important to differentiate between the latency of successful requests and the latency of failed requests.
2. **Traffic**: A measure of how much demand is being placed on your system (e.g., HTTP requests per second, or bandwidth on a network interface).
3. **Errors**: The rate of requests that fail, either explicitly (e.g., HTTP 500s), implicitly (e.g., a 200 OK but with the wrong content), or by policy (e.g., requests that took longer than 1s).
4. **Saturation**: How "full" your service is. A measure of your system fraction (e.g., CPU utilization, memory usage, or disk I/O).

---

## 🌩️ 2. White-box vs Black-box Monitoring

### White-box Monitoring
Monitoring based on metrics exposed by the internals of the system (e.g., logs, JVM metrics, custom application counters).
- **Goal**: Understand *why* something is happening.

### Black-box Monitoring
Monitoring when you test from the outside as a user would (e.g., pings, port checks, synthetic transactions).
- **Goal**: Understand *if* the system is working.

---

## 🛡️ 3. Essential Infrastructure Metrics
Every server should track:
- **CPU**: Load Average, Utilization per core, I/O Wait.
- **Memory**: Physical RAM usage, Swap usage, Page faults.
- **Disk**: Free space, Disk Latency (ms), IOPS.
- **Network**: Megabits per second, Packet drops, Error rate.

---

## 💡 Key Takeaway
Monitoring tells you **that** something is wrong. Observability tells you **why** it is wrong.
