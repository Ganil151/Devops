# Google Cloud Networking

Comprehensive guide to GCP networking services including VPC, Load Balancing, and Cloud CDN.

## Virtual Private Cloud (VPC)
```bash
# Create VPC network
gcloud compute networks create my-vpc --subnet-mode=custom

# Create subnet
gcloud compute networks subnets create my-subnet \
  --network=my-vpc \
  --range=10.0.1.0/24 \
  --region=us-central1

# Create firewall rule
gcloud compute firewall-rules create allow-ssh \
  --network=my-vpc \
  --allow=tcp:22 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=ssh-server

# Create firewall rule for HTTP
gcloud compute firewall-rules create allow-http \
  --network=my-vpc \
  --allow=tcp:80 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=web-server
```

## Load Balancing
```bash
# Create instance template
gcloud compute instance-templates create web-template \
  --machine-type=e2-medium \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud \
  --tags=web-server \
  --metadata=startup-script='#!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx'

# Create managed instance group
gcloud compute instance-groups managed create web-group \
  --template=web-template \
  --size=3 \
  --zone=us-central1-a

# Create health check
gcloud compute health-checks create http web-health-check \
  --port=80 \
  --request-path=/

# Create backend service
gcloud compute backend-services create web-backend \
  --protocol=HTTP \
  --health-checks=web-health-check \
  --global

# Add instance group to backend service
gcloud compute backend-services add-backend web-backend \
  --instance-group=web-group \
  --instance-group-zone=us-central1-a \
  --global

# Create URL map
gcloud compute url-maps create web-map \
  --default-service=web-backend

# Create HTTP proxy
gcloud compute target-http-proxies create web-proxy \
  --url-map=web-map

# Create global forwarding rule
gcloud compute forwarding-rules create web-rule \
  --global \
  --target-http-proxy=web-proxy \
  --ports=80
```

## Cloud CDN
```bash
# Enable Cloud CDN on backend service
gcloud compute backend-services update web-backend \
  --enable-cdn \
  --global

# Set cache mode
gcloud compute backend-services update web-backend \
  --cache-mode=CACHE_ALL_STATIC \
  --global
```

## VPN and Interconnect
```bash
# Create VPN gateway
gcloud compute vpn-gateways create my-vpn-gateway \
  --network=my-vpc \
  --region=us-central1

# Create VPN tunnel
gcloud compute vpn-tunnels create my-tunnel \
  --peer-address=203.0.113.12 \
  --shared-secret=mysharedsecret \
  --target-vpn-gateway=my-vpn-gateway \
  --region=us-central1

# Create route for VPN
gcloud compute routes create my-route \
  --network=my-vpc \
  --next-hop-vpn-tunnel=my-tunnel \
  --next-hop-vpn-tunnel-region=us-central1 \
  --destination-range=192.168.1.0/24
```

This guide covers GCP networking for secure and scalable cloud connectivity.