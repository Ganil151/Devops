# Advanced Level: Certificates & TLS

Security in Kubernetes often relies on PKI (Public Key Infrastructure). Components talk to each other using mTLS, and external traffic is secured via TLS.

## 🎯 Learning Objectives
- Understand Kubernetes **CertificateAuthority (CA)**.
- Manage certificates manually.
- Automate certificate management with **cert-manager**.

## 1. Kubernetes PKI
Kubernetes requires PKI for the following operations:
- Client certificates for the kubelet to authenticate to the API server.
- Server certificate for the API server endpoint.
- Client certificates for administrators (kubectl).
- Etcd peer authentication.

## 2. Certificate Signing Requests (CSR)
Kubernetes has a built-in API for managing certificates.

1. Generate a key and CSR on your local machine:
   ```bash
   openssl req -new -key myuser.key -out myuser.csr -subj "/CN=myuser/O=devs"
   ```
2. Create a `CertificateSigningRequest` object in k8s.
3. Approve the CSR:
   ```bash
   kubectl certificate approve myuser
   ```
4. Extract the signed certificate.

## 3. Cert-Manager (The Standard)
[Cert-manager](https://cert-manager.io/) is the de-facto tool for automating certificates in Kubernetes.

### Concepts
- **Issuer**: Represents a certificate authority (e.g., Let's Encrypt).
- **Certificate**: A request for a certificate (which tracks the renewal).

### Example: Let's Encrypt with Ingress
```yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: user@example.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

[Back to Advanced Index](../readme.md)
