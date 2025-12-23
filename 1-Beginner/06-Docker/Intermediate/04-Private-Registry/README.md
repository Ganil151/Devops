# Setting Up a Private Docker Registry

For many organizations, using Docker Hub is either not cost-effective or violates security policies regarding data sovereignty. Hosting your own private Docker Registry allows you to keep your container images within your own infrastructure, speeding up deployments and enhancing security.

## Prerequisites
- A server with Docker installed
- `openssl` for generating certificates

## 1. Generating SSL Certificates

To ensure secure communication, we should use SSL. We will generate a self-signed certificate for this guide.

```bash
# Create a directory for certificates
mkdir -p certs

# Generate self-signed certificate
openssl req -newkey rsa:2048 -nodes -keyout certs/registry.key \
  -x509 -days 365 -out certs/registry.crt
```

> [!IMPORTANT]
> When prompted for **Common Name (CN)**, ensure you enter the specific hostname or IP address where the registry will be accessible (e.g., `myregistry.local` or `192.168.1.5`).

## 2. Running the Registry Container

We will use the official `registry:2` image and mount our certificates.

```bash
docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  -v "$(pwd)"/certs:/certs \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key \
  registry:2
```

## 3. Configuring Docker Clients

Since we are using a self-signed certificate, we must explicitly tell every Docker client to trust it.

On **every client machine** that needs to pull/push:
1.  Create the directory: `/etc/docker/certs.d/<registry-domain>:5000/`
2.  Copy your `registry.crt` file into that directory and name it `ca.crt`.

```bash
# Example
sudo mkdir -p /etc/docker/certs.d/myregistry.local:5000/
sudo cp registry.crt /etc/docker/certs.d/myregistry.local:5000/ca.crt
```

## 4. Managing Images

### Tagging an Image
To push an image to your private registry, you must tag it with the registry's address.

```bash
# Tag an existing image (e.g., ubuntu)
docker tag ubuntu:latest myregistry.local:5000/my-ubuntu:v1
```

### Pushing an Image
```bash
docker push myregistry.local:5000/my-ubuntu:v1
```

### Pulling an Image
On any other machine (properly configured):
```bash
docker pull myregistry.local:5000/my-ubuntu:v1
```

## 5. Storage Persistence

By default, the registry container stores data inside the container. To persist data (images) across restarts, mount a host directory:

```bash
docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  -v /mnt/registry-data:/var/lib/registry \
  -v "$(pwd)"/certs:/certs \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key \
  registry:2
```

## Resources
- [Official Registry Docs](https://docs.docker.com/registry/)
- [Configuring a Registry](https://docs.docker.com/registry/configuration/)
