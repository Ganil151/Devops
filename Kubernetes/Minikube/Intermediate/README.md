# Intermediate Level: Configuring Minikube

Now that you have a running cluster, let's look at how to customize it for development workflows and better performance.

## 🎯 Learning Objectives
- Manage different types of **Drivers**.
- Configure cluster resources (CPU/Memory).
- Enable **Addons** for extra functionality.
- Work with local container images.

## 1. Drivers and Runtimes
Minikube supports multiple drivers. Docker is the preferred driver, but you often need a VM driver (like VirtualBox or VMware) if:
- You are on an older OS without Docker support.
- You need to simulate a full VM environment.
- You want to use a specific hypervisor you are familiar with.

### VirtualBox
**Prerequisites**: Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) first.

```bash
minikube start --driver=virtualbox
```

### VMware
**Prerequisites**: Install [VMware Fusion](https://www.vmware.com/products/fusion.html) (macOS) or [Workstation](https://www.vmware.com/products/workstation-pro.html) (Linux/Windows).

```bash
minikube start --driver=vmware
```

### KVM (Linux Only)
**Prerequisites**: Install KVM, libvirt, and qemu-kvm.

```bash
minikube start --driver=kvm2
```

## 2. Kubernetes Version
Sometimes you need to match a specific Kubernetes version (e.g., to match your production environment which might be running an older version).

```bash
minikube start --kubernetes-version=v1.34.0 --driver=docker
```
- `--kubernetes-version`: Specifies the exact version of the Kubernetes API server, Controller Manager, etc.
- `--driver=docker`: Explicitly sets the driver, ensuring you are using containers.

## 3. Resource Configuration
By default, Minikube uses conservative resource limits. For heavier workloads, you should increase them.

```bash
# Start with more resources
minikube start --cpus 4 --memory 8192
```

To make these changes permanent:
```bash
minikube config set cpus 4
minikube config set memory 8192
```

## 4. Addons
Addons are extensions that can be enabled or disabled in Minikube.

```bash
# List all addons
minikube addons list

# Enable the Ingress Controller (very common)
minikube addons enable ingress

# Enable Metrics Server (for HPA)
minikube addons enable metrics-server
```

## 5. Working with Local Images
When developing locally, you don't want to push to Docker Hub every time you make a change.

### The Minikube Docker Environment
You can point your terminal's docker client to the docker daemon *inside* Minikube.
```bash
eval $(minikube docker-env)
```
Now, when you run `docker build -t my-app .`, the image exists directly inside the cluster!

### Loading Images
Alternatively, if you built an image on your host:
```bash
minikube image load my-app:v1
```

## 6. Mounting Volumes
To mount a directory from your host into the Minikube VM:
```bash
minikube mount /home/user/data:/data
```

[Back: Beginner Level](../Beginner/README.md) | [Next: Advanced Level](../Advanced/README.md)
