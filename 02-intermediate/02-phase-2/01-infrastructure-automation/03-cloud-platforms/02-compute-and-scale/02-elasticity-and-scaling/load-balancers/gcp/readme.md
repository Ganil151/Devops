# Google Cloud Load Balancing

Complete guide to Google Cloud load balancing services, configuration, and implementation.

## Global HTTP(S) Load Balancer
```bash
# Global Layer 7 load balancer
# Anycast IP addresses
# SSL termination and CDN integration

Create HTTP Load Balancer:
gcloud compute url-maps create web-map \
    --default-service web-backend-service

gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map

gcloud compute forwarding-rules create http-content-rule \
    --global \
    --target-http-proxy http-lb-proxy \
    --ports 80
```

## Network Load Balancer
```bash
# Regional Layer 4 load balancer
# TCP/UDP traffic
# High performance and low latency

Create Network Load Balancer:
gcloud compute forwarding-rules create my-forwarding-rule \
    --region us-central1 \
    --ports 80 \
    --backend-service my-backend-service
```

## Internal Load Balancer
```bash
# Private load balancing
# VPC internal traffic
# Regional service

Create Internal Load Balancer:
gcloud compute forwarding-rules create my-internal-lb \
    --region us-central1 \
    --load-balancing-scheme internal \
    --backend-service my-internal-backend \
    --subnet my-subnet \
    --ports 80
```

## Cloud CDN Integration
```bash
# Content delivery network
# Global edge caching
# Performance optimization

Enable Cloud CDN:
gcloud compute backend-services update web-backend-service \
    --enable-cdn \
    --global
```