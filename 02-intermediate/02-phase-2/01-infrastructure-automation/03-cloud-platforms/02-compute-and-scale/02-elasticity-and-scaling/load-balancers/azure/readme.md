# Azure Load Balancing

Complete guide to Azure load balancing services, configuration, and best practices.

## Azure Load Balancer
```bash
# Layer 4 (TCP/UDP) load balancer
# Internal and external options
# High availability and scalability

Create Load Balancer:
az network lb create \
    --resource-group myResourceGroup \
    --name myLoadBalancer \
    --sku Standard \
    --public-ip-address myPublicIP \
    --frontend-ip-name myFrontEnd \
    --backend-pool-name myBackEndPool
```

## Application Gateway
```bash
# Layer 7 (HTTP/HTTPS) load balancer
# Web application firewall
# SSL termination and routing

Create Application Gateway:
az network application-gateway create \
    --name myAppGateway \
    --location eastus \
    --resource-group myResourceGroup \
    --vnet-name myVNet \
    --subnet mySubnet \
    --capacity 2 \
    --sku Standard_v2 \
    --http-settings-cookie-based-affinity Disabled \
    --frontend-port 80 \
    --http-settings-port 80 \
    --http-settings-protocol Http \
    --public-ip-address myPublicIP
```

## Azure Front Door
```bash
# Global load balancer
# CDN and WAF integration
# Multi-region routing

Create Front Door:
az network front-door create \
    --resource-group myResourceGroup \
    --name myFrontDoor \
    --accepted-protocols Http Https \
    --protocol-type ServerNameIndication \
    --backend-address backend1.example.com \
    --backend-host-header backend1.example.com
```

## Traffic Manager
```bash
# DNS-based load balancer
# Global traffic routing
# Multiple routing methods

Create Traffic Manager Profile:
az network traffic-manager profile create \
    --name myTMProfile \
    --resource-group myResourceGroup \
    --routing-method Performance \
    --unique-dns-name myuniquednsname \
    --ttl 30 \
    --protocol HTTP \
    --port 80 \
    --path "/"
```