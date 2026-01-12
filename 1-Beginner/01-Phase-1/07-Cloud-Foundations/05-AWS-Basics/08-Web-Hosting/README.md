# AWS Web Hosting (Route53 & CloudFront)

DNS and Content Delivery.

## Architecture: Web Request Flow
```mermaid
graph LR
    User[User Browser]
    DNS[Route53 DNS]
    CDN[CloudFront CDN]
    S3[S3 Static Site]

User -->|1. Lookup| DNS
    DNS -->|2. Returns IP| User
    User -->|3. Request| CDN
    CDN -->|4. Get Content| S3
    CDN -->|5. Return Content| User

classDef web fill:#e3f2fd,stroke:#0d47a1
    class DNS,CDN web
```

## Real World Scenarios
### Scenario: Global Marketing Site
**Context:** High traffic launch for a new product page. Users are worldwide.
**Solution:**
- **S3:** Host the static HTML/CSS/JS.
- **CloudFront:** Cache the site at Edge Locations globally.
- **Route53:** Latency-based routing (optional) or simple Alias record to CloudFront.
**Benefit:** Fastest possible load times, low cost, 99.99% availability, survives massive traffic spikes.

<b>1. Route53 is a:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Highly available and scalable DNS web service</b>
</details>


<b>2. "53" in Route53 refers to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) The TCP/UDP port for DNS</b>
</details>


<b>3. An "Alias Record" in Route53 is better than CNAME because:</b>
<details>
<summary>Show Answer</summary>
Answer: A) It can point to AWS root resources (like ELB/CloudFront) and is free for queries</b>
</details>


<b>4. Which Routing Policy routes traffic to the Region with the fastest response time?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Latency Routing</b>
</details>


<b>5. Which Routing Policy routes traffic based on the user's physical location (Country/State)?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Geolocation Routing</b>
</details>


<b>6. CloudFront is a:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Content Delivery Network (CDN)</b>
</details>


<b>7. "TTL" (Time To Live) determines:</b>
<details>
<summary>Show Answer</summary>
Answer: A) How long a DNS record is cached by the resolver</b>
</details>


<b>8. Route53 Health Checks can:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Monitor endpoint health and trigger failover</b>
</details>


<b>9. Weighted Routing is used for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) A/B Testing (e.g., 10% to new version, 90% to old)</b>
</details>


<b>10. Route53 is a Global Service. (True/False)</b>
<details>
<summary>Show Answer</summary>
Answer: A) True</b>
</details>


<b>11. Can Route53 register domain names?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes (Registrar)</b>
</details>


<b>12. CloudFront "Origin" can be:</b>
<details>
<summary>Show Answer</summary>
Answer: A) S3 Bucket, Load Balancer, EC2, or custom HTTP server</b>
</details>


<b>13. "OAI" (Origin Access Identity) is used to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Restrict access to an S3 bucket so only CloudFront can access it</b>
</details>


<b>14. CloudFront signed URLs are for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Restricted content access (Paid content, private)</b>
</details>


<b>15. Dynamic Content (API) via CloudFront:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Is optimized via the AWS private network backbone to the origin</b>
</details>


<b>16. Route53 Failover record type:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Directs traffic to a backup resource if the primary is unhealthy</b>
</details>


<b>17. Lambda@Edge runs:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Code at CloudFront Edge Locations (closest to user)</b>
</details>


<b>18. Can you host a Zone Apex (e.g., example.com) on an ELB?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes, using Route53 Alias Record</b>
</details>


<b>19. Geo-Proximity Routing uses:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Bias values to shift traffic usage between geographic regions</b>
</details>


<b>20. To prevent DDoS attacks at the Edge, CloudFront integrates with:</b>
<details>
<summary>Show Answer</summary>
Answer: A) AWS Shield and WAF</b>
</details>


<b>21. Multi-Value Answer Routing:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Returns multiple healthy IP addresses (Simple Load Balancing)</b>
</details>
