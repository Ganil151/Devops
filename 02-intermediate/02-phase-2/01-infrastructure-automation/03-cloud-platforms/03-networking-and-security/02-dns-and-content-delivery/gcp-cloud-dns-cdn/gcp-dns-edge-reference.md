# GCP Cloud DNS & Cloud CDN Reference

Google Cloud DNS is a scalable, reliable, and managed authoritative Domain Name System (DNS) service running on the same infrastructure as Google. Google Cloud CDN uses Google's globally distributed edge points of presence to cache HTTP(S) load balanced content close to your users.

## ⚡ Key Features
- **Anycast IP**: A single IP address for global load balancing.
- **Edge Caching**: Caching static content from Cloud Storage or Compute Engine.
- **DNSSEC**: Automated DNS security extensions.

## 🛠️ IaC (Terraform)
```hcl
resource "google_compute_managed_zone" "prod_zone" {
  name     = "prod-zone"
  dns_name = "example.com."
}
```
