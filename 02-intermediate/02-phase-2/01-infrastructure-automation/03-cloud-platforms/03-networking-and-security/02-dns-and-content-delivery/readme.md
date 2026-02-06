# 🌍 DNS and Content Delivery: Global Edge Performance

DNS and CDNs are responsible for traffic steering and reducing latency by moving content closer to your users.

## ⚡ Key Components

### 1. Global DNS (The Traffic Controller)
Managing domain names and routing users to the healthiest, nearest endpoint.
- **Failover Routing**: Automatically switching to a backup region if the primary goes down.
- **Geolocation Routing**: Sending users to a server in their own country.

### 2. Content Delivery Network (CDN)
A distributed network of proxy servers and data centers.
- **Caching**: Storing static assets (images, JS) at edge locations.
- **Origin Shield**: Protecting the main server from traffic spikes.
- **SSL Termination**: Handling encryption at the edge.

---

## 🏗️ The "DevOps Why": Origin Offloading
Why use a CDN?
- **Speed**: Content delivered from 10ms away rather than 200ms across the ocean.
- **Cost**: Egress (bandwidth) from a CDN is often cheaper than egress directly from a web server.
- **Protection**: CDNs often have integrated WAFs and DDoS protection, scrubbing traffic before it reaches your expensive compute.

---

## 📂 Multi-Cloud Implementations
- [AWS-Route53-CloudFront](./aws-route53-cloudfront): Integrated edge security and DNS logic.
- [Azure-DNS-FrontDoor](./azure-dns-frontdoor): Global HTTP load balancing and CDN.
- [GCP-Cloud-DNS-CDN](./gcp-cloud-dns-cdn): Fast, global Anycast network.
