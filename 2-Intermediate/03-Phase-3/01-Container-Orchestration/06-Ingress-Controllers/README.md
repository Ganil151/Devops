# Kubernetes Ingress

## Overview

**Kubernetes Ingress** manages external access to services in a cluster, typically HTTP/HTTPS. Ingress provides load balancing, SSL termination, and name-based virtual hosting.

## Basic Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp-service
            port:
              number: 80
```

## TLS Configuration

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp-service
            port:
              number: 80
```

## Path Types

- **Exact**: Matches the URL path exactly
- **Prefix**: Matches based on URL path prefix
- **ImplementationSpecific**: Depends on ingress controller

## Ingress Controllers

### NGINX Ingress Controller
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /app
        pathType: Prefix
        backend:
          service:
            name: myapp-service
            port:
              number: 80
```

## Best Practices

- Use TLS for production traffic
- Implement proper path routing
- Configure rate limiting
- Monitor ingress metrics
- Use appropriate ingress controllers

## Troubleshooting

```bash
# Check ingress status
kubectl get ingress

# Describe ingress
kubectl describe ingress myapp-ingress

# Check ingress controller logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

## Conclusion

Ingress provides a powerful way to manage external access to Kubernetes services with advanced routing, SSL termination, and load balancing capabilities.