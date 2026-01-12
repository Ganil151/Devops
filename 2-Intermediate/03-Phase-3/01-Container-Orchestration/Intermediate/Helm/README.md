# Intermediate Level: Helm Package Manager

Helm is the "package manager" for Kubernetes. It allows you to define, install, and upgrade even the most complex Kubernetes application using "Charts".

## 🎯 Learning Objectives
- Understand what a **Helm Chart** is.
- Install and use the **Helm CLI**.
- Deploy applications from public repositories.
- Customizing deployments with `values.yaml`.

## 1. Concepts
- **Chart**: A collection of files that describe a related set of Kubernetes resources.
- **Release**: A running instance of a Chart in a cluster.
- **Repository**: A place where charts can be collected and shared.

## 2. Basic Commands

### Installation
(See [official docs](https://helm.sh/docs/intro/install/) for your OS)

### Adding Repositories
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### Searching
```bash
helm search repo mysql
```

## 3. Installing a Chart
To install a simple NGINX server:

```bash
helm install my-nginx bitnami/nginx
```
This single command might create Deployments, Services, ConfigMaps, and Secrets automatically.

## 4. Customizing Values
Helm charts use a `values.yaml` file to define defaults. You can override these.

### View Defaults
```bash
helm show values bitnami/nginx
```

### Install with Overrides
Create a file `my-values.yaml`:
```yaml
replicaCount: 3
service:
  type: NodePort
```

Run install/upgrade:
```bash
helm upgrade --install my-nginx bitnami/nginx -f my-values.yaml
```

## 5. Lifecycle Management
```bash
# List all releases
helm list

# Uninstall a release
helm uninstall my-nginx
```

[Back to Intermediate Index](../README.md)
