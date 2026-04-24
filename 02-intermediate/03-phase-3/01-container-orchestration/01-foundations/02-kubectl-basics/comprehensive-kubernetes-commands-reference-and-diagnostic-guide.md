## **kubectl Basics**

### Cluster Information
```bash
# Display cluster information
kubectl cluster-info

# Display cluster info with more details
kubectl cluster-info dump

# Check kubectl version (client and server)
kubectl version

# Check kubectl version in short format
kubectl version --short

# View cluster nodes
kubectl get nodes

# View nodes with detailed information
kubectl get nodes -o wide

# Describe a specific node
kubectl describe node <node_name>

# Check node resource usage
kubectl top nodes

# View cluster configuration
kubectl config view

# Get current context
kubectl config current-context

# List all contexts
kubectl config get-contexts

# Switch context
kubectl config use-context <context_name>

# Set default namespace for current context
kubectl config set-context --current --namespace=<namespace>
```
---

## **Namespace Management**

### Namespace Operations
```bash
# List all namespaces
kubectl get namespaces
kubectl get ns

# Create namespace
kubectl create namespace <namespace_name>

# Create namespace from YAML
kubectl create -f namespace.yaml

# Delete namespace
kubectl delete namespace <namespace_name>

# Describe namespace
kubectl describe namespace <namespace_name>

# Set default namespace for kubectl commands
kubectl config set-context --current --namespace=<namespace_name>

# View resource quotas in namespace
kubectl get resourcequota -n <namespace_name>

# View limit ranges in namespace
kubectl get limitrange -n <namespace_name>
```

---

## **Pod Management**

### Basic Pod Operations

```bash
# List all pods in current namespace
kubectl get pods

# List pods in all namespaces
kubectl get pods --all-namespaces
kubectl get pods -A

# List pods with additional details
kubectl get pods -o wide

# List pods with labels
kubectl get pods --show-labels

# Filter pods by label
kubectl get pods -l app=spring-petclinic

# Get pod in specific namespace
kubectl get pods -n <namespace>

# Describe pod (detailed information)
kubectl describe pod <pod_name>

# Get pod YAML definition
kubectl get pod <pod_name> -o yaml

# Get pod JSON definition
kubectl get pod <pod_name> -o json

# Delete pod
kubectl delete pod <pod_name>

# Force delete pod
kubectl delete pod <pod_name> --force --grace-period=0

# Delete all pods in namespace
kubectl delete pods --all -n <namespace>

# Delete pods by label
kubectl delete pods -l app=spring-petclinic
```
___
### Pod Execution & Interaction
```bash
# Execute command in pod
kubectl exec <pod_name> -- <command>

# Interactive shell in pod
kubectl exec -it <pod_name> -- bash
kubectl exec -it <pod_name> -- sh

# Execute in specific container (multi-container pod)
kubectl exec -it <pod_name> -c <container_name> -- bash

# Run command as specific user
kubectl exec -it <pod_name> -- su - <username>

# Copy files from pod to local
kubectl cp <pod_name>:/path/in/pod /local/path

# Copy files from local to pod
kubectl cp /local/path <pod_name>:/path/in/pod

# Copy from specific container
kubectl cp <pod_name>:/path/in/pod /local/path -c <container_name>

# Port forward to pod
kubectl port-forward <pod_name> <local_port>:<pod_port>

# Port forward example
kubectl port-forward pod/spring-petclinic-api-gateway-xxx 8080:8080

# Attach to running pod
kubectl attach <pod_name> -it
```
___
### Pod Logs
```bash
# View pod logs
kubectl logs <pod_name>

# Follow logs (real-time)
kubectl logs -f <pod_name>

# Logs from specific container
kubectl logs <pod_name> -c <container_name>

# Previous container logs (after restart)
kubectl logs <pod_name> --previous

# Last N lines of logs
kubectl logs <pod_name> --tail=100

# Logs since specific time
kubectl logs <pod_name> --since=1h
kubectl logs <pod_name> --since=10m

# Logs with timestamps
kubectl logs <pod_name> --timestamps

# Logs from all containers in pod
kubectl logs <pod_name> --all-containers=true

# Stream logs from multiple pods
kubectl logs -l app=spring-petclinic -f

# Save logs to file
kubectl logs <pod_name> > pod.log
```
---

## **Deployment Management**

### Deployment Operations
```bash
# List deployments
kubectl get deployments
kubectl get deploy

# List deployments in all namespaces
kubectl get deployments -A

# Get deployment details
kubectl get deployment <deployment_name> -o wide

# Describe deployment
kubectl describe deployment <deployment_name>

# Create deployment
kubectl create deployment <name> --image=<image>

# Create deployment from YAML
kubectl apply -f deployment.yaml

# Update deployment
kubectl apply -f deployment.yaml

# Edit deployment
kubectl edit deployment <deployment_name>

# Scale deployment
kubectl scale deployment <deployment_name> --replicas=3

# Autoscale deployment
kubectl autoscale deployment <deployment_name> --min=2 --max=10 --cpu-percent=80

# Delete deployment
kubectl delete deployment <deployment_name>

# Get deployment rollout status
kubectl rollout status deployment/<deployment_name>

# View rollout history
kubectl rollout history deployment/<deployment_name>

# View specific revision
kubectl rollout history deployment/<deployment_name> --revision=2

# Rollback to previous version
kubectl rollout undo deployment/<deployment_name>

# Rollback to specific revision
kubectl rollout undo deployment/<deployment_name> --to-revision=2

# Pause rollout
kubectl rollout pause deployment/<deployment_name>

# Resume rollout
kubectl rollout resume deployment/<deployment_name>

# Restart deployment
kubectl rollout restart deployment/<deployment_name>
```
### Deployment Strategies
```bash
# Update image
kubectl set image deployment/<deployment_name> <container_name>=<new_image>

# Update multiple containers
kubectl set image deployment/<deployment_name> container1=image1 container2=image2

# Set environment variable
kubectl set env deployment/<deployment_name> KEY=VALUE

# Set resource limits
kubectl set resources deployment <deployment_name> -c=<container> --limits=cpu=200m,memory=512Mi

# Set resource requests
kubectl set resources deployment <deployment_name> -c=<container> --requests=cpu=100m,memory=256Mi
```
---

## **Service Management**

### Service Operations
```bash
# List services
kubectl get services
kubectl get svc

# List services in all namespaces
kubectl get svc -A

# Get service details
kubectl get svc <service_name> -o wide

# Describe service
kubectl describe svc <service_name>

# Create service
kubectl create service clusterip <service_name> --tcp=80:8080

# Expose deployment as service
kubectl expose deployment <deployment_name> --port=80 --target-port=8080 --type=LoadBalancer

# Create service from YAML
kubectl apply -f service.yaml

# Delete service
kubectl delete svc <service_name>

# Get service endpoints
kubectl get endpoints <service_name>

# Get service URL (for LoadBalancer/NodePort)
kubectl get svc <service_name> -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Port forward to service
kubectl port-forward svc/<service_name> <local_port>:<service_port>
```
___
### Service Types
```bash
# Create ClusterIP service (default)
kubectl create service clusterip my-service --tcp=80:8080

# Create NodePort service
kubectl create service nodeport my-service --tcp=80:8080

# Create LoadBalancer service
kubectl create service loadbalancer my-service --tcp=80:8080

# Create ExternalName service
kubectl create service externalname my-service --external-name=example.com
```

---

## **ConfigMap & Secret Management**

### ConfigMap Operations

```bash
# List configmaps
kubectl get configmaps
kubectl get cm

# Describe configmap
kubectl describe cm <configmap_name>

# Create configmap from literal
kubectl create configmap <name> --from-literal=key1=value1 --from-literal=key2=value2

# Create configmap from file
kubectl create configmap <name> --from-file=path/to/file

# Create configmap from directory
kubectl create configmap <name> --from-file=path/to/directory

# Create configmap from env file
kubectl create configmap <name> --from-env-file=path/to/.env

# Get configmap content
kubectl get cm <configmap_name> -o yaml

# Edit configmap
kubectl edit cm <configmap_name>

# Delete configmap
kubectl delete cm <configmap_name>
```

### Secret Operations

```bash
# List secrets
kubectl get secrets

# Describe secret
kubectl describe secret <secret_name>

# Create generic secret from literal
kubectl create secret generic <name> --from-literal=username=admin --from-literal=password=secret

# Create secret from file
kubectl create secret generic <name> --from-file=ssh-key=~/.ssh/id_rsa

# Create TLS secret
kubectl create secret tls <name> --cert=path/to/cert --key=path/to/key

# Create Docker registry secret
kubectl create secret docker-registry <name> \
  --docker-server=<registry> \
  --docker-username=<username> \
  --docker-password=<password> \
  --docker-email=<email>

# Get secret (base64 encoded)
kubectl get secret <secret_name> -o yaml

# Decode secret value
kubectl get secret <secret_name> -o jsonpath='{.data.password}' | base64 --decode

# Edit secret
kubectl edit secret <secret_name>

# Delete secret
kubectl delete secret <secret_name>
```
---

## **Persistent Volumes & Claims**

### PV and PVC Operations
```bash
# List persistent volumes
kubectl get pv

# List persistent volume claims
kubectl get pvc

# List PVCs in specific namespace
kubectl get pvc -n <namespace>

# Describe PV
kubectl describe pv <pv_name>

# Describe PVC
kubectl describe pvc <pvc_name>

# Create PVC from YAML
kubectl apply -f pvc.yaml

# Delete PVC
kubectl delete pvc <pvc_name>

# Get PVC capacity
kubectl get pvc <pvc_name> -o jsonpath='{.spec.resources.requests.storage}'

# Get PVC status
kubectl get pvc <pvc_name> -o jsonpath='{.status.phase}'
```
---

## **Ingress Management**

### Ingress Operations
```bash
# List ingresses
kubectl get ingress
kubectl get ing

# List ingresses in all namespaces
kubectl get ing -A

# Describe ingress
kubectl describe ing <ingress_name>

# Create ingress from YAML
kubectl apply -f ingress.yaml

# Edit ingress
kubectl edit ing <ingress_name>

# Delete ingress
kubectl delete ing <ingress_name>

# Get ingress details
kubectl get ing <ingress_name> -o yaml
```
---

## **StatefulSet Management**

### StatefulSet Operations
```bash
# List statefulsets
kubectl get statefulsets
kubectl get sts

# Describe statefulset
kubectl describe sts <statefulset_name>

# Scale statefulset
kubectl scale sts <statefulset_name> --replicas=3

# Update statefulset
kubectl apply -f statefulset.yaml

# Delete statefulset (keep pods)
kubectl delete sts <statefulset_name> --cascade=orphan

# Rollout restart
kubectl rollout restart sts/<statefulset_name>

# Get rollout status
kubectl rollout status sts/<statefulset_name>
```
---

## **DaemonSet Management**

### DaemonSet Operations
```bash
# List daemonsets
kubectl get daemonsets
kubectl get ds

# Describe daemonset
kubectl describe ds <daemonset_name>

# Create daemonset
kubectl apply -f daemonset.yaml

# Update daemonset
kubectl apply -f daemonset.yaml

# Delete daemonset
kubectl delete ds <daemonset_name>

# Rollout status
kubectl rollout status ds/<daemonset_name>
```

---

## **Job & CronJob Management**

### Job Operations
```bash
# List jobs
kubectl get jobs

# Describe job
kubectl describe job <job_name>

# Create job
kubectl create job <name> --image=<image>

# Create job from cronjob
kubectl create job --from=cronjob/<cronjob_name> <job_name>

# Delete job
kubectl delete job <job_name>

# Get job logs
kubectl logs job/<job_name>
```

### CronJob Operations
```bash
# List cronjobs
kubectl get cronjobs
kubectl get cj

# Describe cronjob
kubectl describe cj <cronjob_name>

# Create cronjob
kubectl create cronjob <name> --image=<image> --schedule="*/5 * * * *" -- <command>

# Suspend cronjob
kubectl patch cronjob <cronjob_name> -p '{"spec":{"suspend":true}}'

# Resume cronjob
kubectl patch cronjob <cronjob_name> -p '{"spec":{"suspend":false}}'

# Delete cronjob
kubectl delete cj <cronjob_name>
```

---

## **Resource Management & Monitoring**

### Resource Viewing
```bash
# Get all resources in namespace
kubectl get all

# Get all resources in all namespaces
kubectl get all -A

# Get specific resource types
kubectl get pods,svc,deploy

# Get resources by label
kubectl get all -l app=spring-petclinic

# Get resources with custom columns
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,IP:.status.podIP

# Get resource names only
kubectl get pods -o name

# Watch resources in real-time
kubectl get pods -w

# Get events
kubectl get events

# Get events sorted by timestamp
kubectl get events --sort-by=.metadata.creationTimestamp

# Get events for specific object
kubectl get events --field-selector involvedObject.name=<pod_name>
```

### Resource Usage & Metrics
```bash
# View node resource usage
kubectl top nodes

# View pod resource usage
kubectl top pods

# View pod resource usage in specific namespace
kubectl top pods -n <namespace>

# View pod resource usage with containers
kubectl top pods --containers

# Sort pods by CPU
kubectl top pods --sort-by=cpu

# Sort pods by memory
kubectl top pods --sort-by=memory

# View specific pod metrics
kubectl top pod <pod_name>
```

---

## **Diagnostic Commands**

### Cluster Diagnostics

```bash
# Check component status
kubectl get componentstatuses
kubectl get cs

# Check API server health
kubectl get --raw /healthz

# Check API server readiness
kubectl get --raw /readyz

# Check API server liveness
kubectl get --raw /livez

# List API resources
kubectl api-resources

# List API versions
kubectl api-versions

# Check RBAC permissions
kubectl auth can-i <verb> <resource>

# Check if you can create pods
kubectl auth can-i create pods

# Check permissions for another user
kubectl auth can-i create pods --as=<username>

# List what you can do
kubectl auth can-i --list
```
___
### Pod Diagnostics
```bash
# Get pod status
kubectl get pod <pod_name> -o jsonpath='{.status.phase}'

# Get container statuses
kubectl get pod <pod_name> -o jsonpath='{.status.containerStatuses[*].state}'

# Get pod restart count
kubectl get pod <pod_name> -o jsonpath='{.status.containerStatuses[*].restartCount}'

# Get pod conditions
kubectl get pod <pod_name> -o jsonpath='{.status.conditions[*]}'

# Check if pod is ready
kubectl get pod <pod_name> -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}'

# Get pod node
kubectl get pod <pod_name> -o jsonpath='{.spec.nodeName}'

# Get pod IP
kubectl get pod <pod_name> -o jsonpath='{.status.podIP}'

# Get pod QoS class
kubectl get pod <pod_name> -o jsonpath='{.status.qosClass}'

# Get container images
kubectl get pod <pod_name> -o jsonpath='{.spec.containers[*].image}'

# Check pod events
kubectl describe pod <pod_name> | grep -A 10 Events:

# Get pod in specific format
kubectl get pod <pod_name> -o json | jq '.status.containerStatuses'
```
___
### Network Diagnostics
```bash
# Test DNS resolution
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default

# Test network connectivity
kubectl run -it --rm debug --image=busybox --restart=Never -- wget -O- http://service-name:port

# Create debug pod
kubectl run debug --image=nicolaka/netshoot -it --rm -- bash

# Test connectivity from specific pod
kubectl exec -it <pod_name> -- curl http://service-name:port

# Check service endpoints
kubectl get endpoints <service_name>

# Describe endpoints
kubectl describe endpoints <service_name>

# Test DNS from pod
kubectl exec -it <pod_name> -- nslookup <service_name>

# Check network policies
kubectl get networkpolicies
kubectl get netpol

# Describe network policy
kubectl describe netpol <policy_name>

# Port forward for debugging
kubectl port-forward <pod_name> 8080:8080
```
___
### Storage Diagnostics
```bash
# Check PVC status
kubectl get pvc

# Check which pod uses PVC
kubectl get pods -o json | jq -r '.items[] | select(.spec.volumes[]?.persistentVolumeClaim.claimName=="<pvc_name>") | .metadata.name'

# Check storage class
kubectl get storageclass
kubectl get sc

# Describe storage class
kubectl describe sc <storage_class_name>

# Check PV reclaim policy
kubectl get pv -o custom-columns=NAME:.metadata.name,RECLAIM:.spec.persistentVolumeReclaimPolicy
```
___
### Application Diagnostics (Spring Boot)
```bash
# Check Spring Boot actuator health
kubectl exec <pod_name> -- curl http://localhost:8080/actuator/health

# Check application info
kubectl exec <pod_name> -- curl http://localhost:8080/actuator/info

# Get environment variables
kubectl exec <pod_name> -- curl http://localhost:8080/actuator/env

# Check metrics
kubectl exec <pod_name> -- curl http://localhost:8080/actuator/metrics

# Thread dump
kubectl exec <pod_name> -- curl http://localhost:8080/actuator/threaddump

# Check beans
kubectl exec <pod_name> -- curl http://localhost:8080/actuator/beans
```
___
### Database Diagnostics (MySQL Pod)
```bash
# Connect to MySQL
kubectl exec -it <mysql_pod> -- mysql -u root -p

# Check MySQL process list
kubectl exec <mysql_pod> -- mysql -u root -p<password> -e "SHOW PROCESSLIST;"

# Check database status
kubectl exec <mysql_pod> -- mysql -u root -p<password> -e "SHOW STATUS;"

# Backup database
kubectl exec <mysql_pod> -- mysqldump -u root -p<password> <database> > backup.sql

# Check MySQL logs
kubectl logs <mysql_pod>
```
---

## **Troubleshooting Commands**

### Common Issues

#### Issue 1: Pod Not Starting

```bash
# Check pod status
kubectl get pod <pod_name>

# Get detailed information
kubectl describe pod <pod_name>

# Check events
kubectl get events --field-selector involvedObject.name=<pod_name>

# Check logs
kubectl logs <pod_name>

# Check previous logs if pod restarted
kubectl logs <pod_name> --previous

# Check all container logs
kubectl logs <pod_name> --all-containers=true
```
___
#### Issue 2: CrashLoopBackOff
```bash
# View pod logs
kubectl logs <pod_name>

# View previous container logs
kubectl logs <pod_name> --previous

# Describe pod for events
kubectl describe pod <pod_name>

# Check liveness/readiness probes
kubectl get pod <pod_name> -o yaml | grep -A 5 "livenessProbe\|readinessProbe"

# Increase verbosity
kubectl logs <pod_name> --previous -v=8
```
___
#### Issue 3: ImagePullBackOff
```bash
# Check image name
kubectl get pod <pod_name> -o jsonpath='{.spec.containers[*].image}'

# Check image pull secrets
kubectl get pod <pod_name> -o jsonpath='{.spec.imagePullSecrets}'

# Describe pod for error details
kubectl describe pod <pod_name> | grep -A 10 "Events:"

# Check if secret exists
kubectl get secrets

# Verify credentials in secret
kubectl get secret <secret_name> -o yaml
```
___
#### Issue 4: Service Not Accessible
```bash
# Check service exists
kubectl get svc <service_name>

# Check endpoints
kubectl get endpoints <service_name>

# Verify selector matches pods
kubectl get svc <service_name> -o yaml | grep selector -A 5
kubectl get pods --show-labels

# Test from within cluster
kubectl run test --image=busybox -it --rm -- wget -O- http://<service_name>:<port>

# Check network policies
kubectl get networkpolicies
```
___
#### Issue 5: Persistent Volume Issues
```bash
# Check PVC status
kubectl get pvc <pvc_name>

# Check if PV is bound
kubectl get pv

# Describe PVC for events
kubectl describe pvc <pvc_name>

# Check storage class
kubectl get sc

# Verify volume mounts in pod
kubectl get pod <pod_name> -o yaml | grep -A 10 volumeMounts
```

---

## **Advanced Operations**

### Patch Resources

```bash
# Patch deployment
kubectl patch deployment <name> -p '{"spec":{"replicas":3}}'

# Patch using JSON
kubectl patch pod <pod_name> -p '{"metadata":{"labels":{"env":"prod"}}}'

# Patch using strategic merge
kubectl patch deployment <name> --type='strategic' -p '{"spec":{"template":{"spec":{"containers":[{"name":"app","image":"new-image"}]}}}}'

# Patch using JSON merge
kubectl patch deployment <name> --type='merge' -p '{"spec":{"replicas":5}}'
```
___
### Label & Annotate
```bash
# Add label to pod
kubectl label pod <pod_name> env=prod

# Update existing label
kubectl label pod <pod_name> env=staging --overwrite

# Remove label
kubectl label pod <pod_name> env-

# Add annotation
kubectl annotate pod <pod_name> description="my pod"

# Remove annotation
kubectl annotate pod <pod_name> description-

# Label multiple resources
kubectl label pods --all env=prod
```
### Taint & Toleration
```bash
# Add taint to node
kubectl taint nodes <node_name> key=value:NoSchedule

# Remove taint
kubectl taint nodes <node_name> key:NoSchedule-

# View node taints
kubectl describe node <node_name> | grep Taints
```
___
### Cordon & Drain
```bash
# Cordon node (mark unschedulable)
kubectl cordon <node_name>

# Uncordon node
kubectl uncordon <node_name>

# Drain node (evict pods)
kubectl drain <node_name> --ignore-daemonsets --delete-emptydir-data

# Drain with grace period
kubectl drain <node_name> --grace-period=300 --ignore-daemonsets
```

---

## **YAML Management**

### YAML Operations

```bash
# Apply configuration
kubectl apply -f config.yaml

# Apply all YAMLs in directory
kubectl apply -f ./configs/

# Apply with recursive search
kubectl apply -R -f ./configs/

# Dry run (see what would be applied)
kubectl apply -f config.yaml --dry-run=client

# Dry run with server validation
kubectl apply -f config.yaml --dry-run=server

# Show diff before applying
kubectl diff -f config.yaml

# Delete resources from YAML
kubectl delete -f config.yaml

# Validate YAML without applying
kubectl apply -f config.yaml --dry-run=client --validate=true

# Generate YAML from command
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deployment.yaml

# Export existing resource to YAML
kubectl get deployment <name> -o yaml > deployment.yaml

# Replace resource (delete and recreate)
kubectl replace -f config.yaml

# Force replace
kubectl replace -f config.yaml --force
```
---

## **Context & Configuration**

### Context Management
```bash
# View config
kubectl config view

# Get current context
kubectl config current-context

# List contexts
kubectl config get-contexts

# Switch context
kubectl config use-context <context_name>

# Create context
kubectl config set-context <context_name> --cluster=<cluster> --user=<user> --namespace=<namespace>

# Delete context
kubectl config delete-context <context_name>

# Rename context
kubectl config rename-context <old_name> <new_name>

# Set default namespace
kubectl config set-context --current --namespace=<namespace>
```

### Kubeconfig Management

```bash
# Set cluster
kubectl config set-cluster <cluster_name> --server=https://1.2.3.4 --certificate-authority=ca.crt

# Set credentials
kubectl config set-credentials <user_name> --token=<token>

# Set context
kubectl config set-context <context_name> --cluster=<cluster> --user=<user>

# Use specific kubeconfig
kubectl --kubeconfig=/path/to/config get pods

# Merge kubeconfigs
KUBECONFIG=~/.kube/config:~/.kube/config2 kubectl config view --flatten > ~/.kube/merged_config
```
---

## **Comprehensive Diagnostic Script**

Save this as `k8s-diagnose.sh`:
```bash
#!/bin/bash

echo "=== Cluster Information ==="
kubectl cluster-info
kubectl version --short

echo -e "\n=== Node Status ==="
kubectl get nodes -o wide

echo -e "\n=== Node Resource Usage ==="
kubectl top nodes 2>/dev/null || echo "Metrics server not available"

echo -e "\n=== All Namespaces ==="
kubectl get ns

echo -e "\n=== Pods in All Namespaces ==="
kubectl get pods -A -o wide

echo -e "\n=== Pod Resource Usage ==="
kubectl top pods -A 2>/dev/null || echo "Metrics server not available"

echo -e "\n=== Failed/Pending Pods ==="
kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded

echo -e "\n=== Recent Events ==="
kubectl get events -A --sort-by='.lastTimestamp' | tail -20

echo -e "\n=== Services ==="
kubectl get svc -A

echo -e "\n=== Deployments ==="
kubectl get deployments -A

echo -e "\n=== StatefulSets ==="
kubectl get statefulsets -A

echo -e "\n=== PersistentVolumeClaims ==="
kubectl get pvc -A

echo -e "\n=== ConfigMaps ==="
kubectl get cm -A

echo -e "\n=== Secrets ==="
kubectl get secrets -A

echo -e "\n=== Ingresses ==="
kubectl get ingress -A

echo -e "\n=== Component Status ==="
kubectl get componentstatuses

echo -e "\n=== Checking for Unhealthy Pods ==="
for pod in $(kubectl get pods -A -o json | jq -r '.items[] | select(.status.phase!="Running" and .status.phase!="Succeeded") | "\(.metadata.namespace)/\(.metadata.name)"'); do
    echo "--- Unhealthy Pod: $pod ---"
    kubectl describe pod $pod | tail -20
done

echo -e "\n=== Recent Pod Restarts ==="
kubectl get pods -A -o json | jq -r '.items[] | select(.status.containerStatuses[]?.restartCount > 0) | "\(.metadata.namespace)/\(.metadata.name): \(.status.containerStatuses[].restartCount) restarts"'

echo -e "\n=== Disk Usage ==="
df -h | grep -E 'Filesystem|/dev/'

echo -e "\n=== System Load ==="
uptime
```

Make it executable:
```bash
chmod +x k8s-diagnose.sh
./k8s-diagnose.sh
```
---

## **Namespace-Specific Diagnostic Script**

Save this as `k8s-namespace-diagnose.sh`:
```bash
#!/bin/bash

NAMESPACE=${1:-default}

echo "=== Diagnosing Namespace: $NAMESPACE ==="

echo -e "\n=== Pods ==="
kubectl get pods -n $NAMESPACE -o wide

echo -e "\n=== Pod Resource Usage ==="
kubectl top pods -n $NAMESPACE 2>/dev/null || echo "Metrics server not available"

echo -e "\n=== Services ==="
kubectl get svc -n $NAMESPACE

echo -e "\n=== Deployments ==="
kubectl get deployments -n $NAMESPACE

echo -e "\n=== ConfigMaps ==="
kubectl get cm -n $NAMESPACE

echo -e "\n=== Secrets ==="
kubectl get secrets -n $NAMESPACE

echo -e "\n=== Events ==="
kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' | tail -20

echo -e "\n=== Checking Pod Logs for Errors ==="
for pod in $(kubectl get pods -n $NAMESPACE -o name); do
    echo "--- $pod ---"
    kubectl logs -n $NAMESPACE $pod --tail=10 2>&1 | grep -i "error\|exception\|fatal" | head -5
done

echo -e "\n=== Pod Restart Count ==="
kubectl get pods -n $NAMESPACE -o json | jq -r '.items[] | "\(.metadata.name): \(.status.containerStatuses[]?.restartCount // 0) restarts"'
```

Usage:

```bash
chmod +x k8s-namespace-diagnose.sh
./k8s-namespace-diagnose.sh <namespace_name>
```
---

This comprehensive guide covers most Kubernetes operations needed for managing and troubleshooting your Spring Petclinic microservices deployment!