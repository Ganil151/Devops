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

## Quiz
<details>
<summary><b>1. Route53 is a:</b></summary>
A) Highly available and scalable DNS web service<br>
B) Router hardware<br>
C) Road map<br>
D) Database<br>
<br>
<b>Answer: A) Highly available and scalable DNS web service</b>
</details>

<details>
<summary><b>2. "53" in Route53 refers to:</b></summary>
A) The TCP/UDP port for DNS<br>
B) The year it was founded<br>
C) Number of regions<br>
D) Nothing<br>
<br>
<b>Answer: A) The TCP/UDP port for DNS</b>
</details>

<details>
<summary><b>3. An "Alias Record" in Route53 is better than CNAME because:</b></summary>
A) It can point to AWS root resources (like ELB/CloudFront) and is free for queries<br>
B) It is faster<br>
C) It is red<br>
D) CNAME is deprecated<br>
<br>
<b>Answer: A) It can point to AWS root resources (like ELB/CloudFront) and is free for queries</b>
</details>

<details>
<summary><b>4. Which Routing Policy routes traffic to the Region with the fastest response time?</b></summary>
A) Latency Routing<br>
B) Simple Routing<br>
C) Geolocation Routing<br>
D) Failover Routing<br>
<br>
<b>Answer: A) Latency Routing</b>
</details>

<details>
<summary><b>5. Which Routing Policy routes traffic based on the user's physical location (Country/State)?</b></summary>
A) Geolocation Routing<br>
B) Latency Routing<br>
C) Weighted Routing<br>
D) Simple Routing<br>
<br>
<b>Answer: A) Geolocation Routing</b>
</details>

<details>
<summary><b>6. CloudFront is a:</b></summary>
A) Content Delivery Network (CDN)<br>
B) Cloud server<br>
C) Front-end framework<br>
D) Storage<br>
<br>
<b>Answer: A) Content Delivery Network (CDN)</b>
</details>

<details>
<summary><b>7. "TTL" (Time To Live) determines:</b></summary>
A) How long a DNS record is cached by the resolver<br>
B) Steps to live<br>
C) Uptime<br>
D) Cost<br>
<br>
<b>Answer: A) How long a DNS record is cached by the resolver</b>
</details>

<details>
<summary><b>8. Route53 Health Checks can:</b></summary>
A) Monitor endpoint health and trigger failover<br>
B) Check your blood pressure<br>
C) Monitor costs<br>
D) Delete records<br>
<br>
<b>Answer: A) Monitor endpoint health and trigger failover</b>
</details>

<details>
<summary><b>9. Weighted Routing is used for:</b></summary>
A) A/B Testing (e.g., 10% to new version, 90% to old)<br>
B) Heavy traffic<br>
C) Load balancing<br>
D) Security<br>
<br>
<b>Answer: A) A/B Testing (e.g., 10% to new version, 90% to old)</b>
</details>

<details>
<summary><b>10. Route53 is a Global Service. (True/False)</b></summary>
A) True<br>
B) False<br>
<br>
<b>Answer: A) True</b>
</details>

<details>
<summary><b>11. Can Route53 register domain names?</b></summary>
A) Yes (Registrar)<br>
B) No<br>
<br>
<b>Answer: A) Yes (Registrar)</b>
</details>

<details>
<summary><b>12. CloudFront "Origin" can be:</b></summary>
A) S3 Bucket, Load Balancer, EC2, or custom HTTP server<br>
B) Only S3<br>
C) Only EC2<br>
D) Only local files<br>
<br>
<b>Answer: A) S3 Bucket, Load Balancer, EC2, or custom HTTP server</b>
</details>

<details>
<summary><b>13. "OAI" (Origin Access Identity) is used to:</b></summary>
A) Restrict access to an S3 bucket so only CloudFront can access it<br>
B) Identify users<br>
C) Login<br>
D) Route traffic<br>
<br>
<b>Answer: A) Restrict access to an S3 bucket so only CloudFront can access it</b>
</details>

<details>
<summary><b>14. CloudFront signed URLs are for:</b></summary>
A) Restricted content access (Paid content, private)<br>
B) Public content<br>
C) Formatting URLs<br>
D) Shortening URLs<br>
<br>
<b>Answer: A) Restricted content access (Paid content, private)</b>
</details>

<details>
<summary><b>15. Dynamic Content (API) via CloudFront:</b></summary>
A) Is optimized via the AWS private network backbone to the origin<br>
B) Is cached forever<br>
C) Is impossible<br>
D) Is slow<br>
<br>
<b>Answer: A) Is optimized via the AWS private network backbone to the origin</b>
</details>

<details>
<summary><b>16. Route53 Failover record type:</b></summary>
A) Directs traffic to a backup resource if the primary is unhealthy<br>
B) Fails request<br>
C) Is default<br>
D) Is weighted<br>
<br>
<b>Answer: A) Directs traffic to a backup resource if the primary is unhealthy</b>
</details>

<details>
<summary><b>17. Lambda@Edge runs:</b></summary>
A) Code at CloudFront Edge Locations (closest to user)<br>
B) In the region<br>
C) On the user device<br>
D) In S3<br>
<br>
<b>Answer: A) Code at CloudFront Edge Locations (closest to user)</b>
</details>

<details>
<summary><b>18. Can you host a Zone Apex (e.g., example.com) on an ELB?</b></summary>
A) Yes, using Route53 Alias Record<br>
B) No, CNAME limitations<br>
<br>
<b>Answer: A) Yes, using Route53 Alias Record</b>
</details>

<details>
<summary><b>19. Geo-Proximity Routing uses:</b></summary>
A) Bias values to shift traffic usage between geographic regions<br>
B) Latency<br>
C) Failover<br>
D) Weights<br>
<br>
<b>Answer: A) Bias values to shift traffic usage between geographic regions</b>
</details>

<details>
<summary><b>20. To prevent DDoS attacks at the Edge, CloudFront integrates with:</b></summary>
A) AWS Shield and WAF<br>
B) Security Groups<br>
C) IAM<br>
D) S3<br>
<br>
<b>Answer: A) AWS Shield and WAF</b>
</details>

<details>
<summary><b>21. Multi-Value Answer Routing:</b></summary>
A) Returns multiple healthy IP addresses (Simple Load Balancing)<br>
B) Returns one value<br>
C) Is complex<br>
D) Is precise<br>
<br>
<b>Answer: A) Returns multiple healthy IP addresses (Simple Load Balancing)</b>
</details>
