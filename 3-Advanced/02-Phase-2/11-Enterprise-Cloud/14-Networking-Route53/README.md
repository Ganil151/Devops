# Networking & DNS - Advanced (Route 53)

Enterprise-grade routing, hybrid cloud integration, and security.

## Guides

### [Advanced Route 53 Patterns & Troubleshooting](route53-advanced-patterns.md)
Deep dive into:
- Complex Routing Policies (Weighted, Latency, Failover, etc.).
- Hybrid DNS with Route 53 Resolver.
- DNSSEC configuration for domain security.
- Production-level troubleshooting with `dig` and `test-dns-answer`.

## Best Practices Checklist
- [ ] Use **Alias Records** for all AWS resource mapping (Free and faster).
- [ ] Configure **Health Checks** for automated failover.
- [ ] Monitor DNS query logs in CloudWatch for audit and security.
- [ ] Set high TTLs for static records (cost saving) and low TTLs for dynamic resources (fast failover).
