# Advanced Level: Minikube for Power Users

Minikube is surprisingly capable and can simulate complex production scenarios including multi-node setups and network tunnels.

## 🎯 Learning Objectives
- Create and manage **Multi-Node Clusters**.
- Use **Profiles** for multiple isolated clusters.
- Advanced **Networking** and Tunneling.
- **Embedding** Minikube for testing.

## 1. Multi-Node Clusters
You can simulate a real distributed Kubernetes cluster on your single machine.

```bash
# Start a 3-node cluster
minikube start --nodes 3 -p multinode-demo
```

### Managing Nodes
```bash
# Check status of specific node
minikube status -p multinode-demo

# SSH into a worker node
minikube ssh -n multinode-demo-m02
```
This is excellent for testing pod affinity, anti-affinity, and node failure resilience.

## 2. Profiles
Profiles allow you to have multiple distinct Minikube instances (clusters) running simultaneously or saved for later.

```bash
# Create a separate cluster for a specific project
minikube start -p project-x

# Create another for a different version of K8s
minikube start -p legacy-project --kubernetes-version=v1.20.0

# List all profiles
minikube profile list

# Switch context
minikube profile project-x
```
*Note: Each running profile consumes additional RAM and CPU.*

## 3. Advanced Networking

### Minikube Tunnel
`LoadBalancer` services usually don't work in Minikube (they stay in `Pending` state) because there is no cloud provider to provision an IP.
`minikube tunnel` runs as a process on your host and creates a network route to the cluster's service CIDR.

```bash
# In a separate terminal
sudo minikube tunnel
```
Now services of type `LoadBalancer` will define an `EXTERNAL-IP`.

### Service URL
To get multiple URLs for a service:
```bash
minikube service list
```

## 4. Embedding Minikube
For advanced testing scenarios (like in CI/CD pipelines or Go test suites), you can use Minikube as a library.
(See [Minikube Go Library](https://pkg.go.dev/k8s.io/minikube/pkg/minikube/libmachine) documentation)

[Back: Intermediate Level](../intermediate/readme.md) | [Minikube Index](../readme.md)
