# 🛡️ Network Tools Best Practices

## 1. Security & Ethics
- **Authorization**: NEVER scan or capture traffic on a network you do not own or have explicit written permission to test.
- **Privacy**: Be aware that packet captures can contain sensitive data (passwords, PII). Encrypt and store capture files securely.

## 2. Efficiency
- **Filters**: Use "Capture Filters" in Tcpdump and Wireshark to limit the amount of data saved to disk.
- **Timing**: In Nmap, use the `-T<0-5>` flag. `-T4` is recommended for stable networks; `-T2` or `-T3` for fragile or low-bandwidth networks.

## 3. Cloud Networking
- **Flow Logs**: In AWS/Azure, use native Flow Logs instead of running packet captures on every instance. It is cheaper and more scalable.
- **Least Privilege**: Only open security group ports that are absolutely necessary for the application.
