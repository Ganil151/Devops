# 🛡️ Best Practices: Professional Packet Analysis

When using tools like Wireshark and Tcpdump in a production environment, follow these professional standards:

## 1. Respect Privacy (The Legal Rule)
- Never capture traffic on a network where you do not have explicit authorization.
- In enterprise environments, capture files may contain PII. Secure them with encryption and follow data retention policies.

## 2. Capture Small, Filter Large (The Efficiency Rule)
- Don't just run `tcpdump -i any`. This will crash your terminal or fill up your disk.
- Use **Capture Filters**: `tcpdump host 10.0.1.5 and port 443`.
- Use **Display Filters**: In Wireshark, use `http.response.code >= 400` to find errors quickly.

## 3. Don't Benchmark with Wireshark (The Performance Rule)
- Packet capture software adds "Observer Bias." It consumes CPU and Memory.
- If you are testing for max throughput, turn OFF the packet capture or use a hardware-accelerated tap.

## 4. The "Golden Capture" Strategy
- Always capture on BOTH ends of the connection (Client and Server).
- This allows you to differentiate between "Network Lag" and "Processing Lag."
