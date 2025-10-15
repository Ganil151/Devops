- **kubectl is the core tool for managing Kubernetes clusters,** enabling you to inspect, deploy, troubleshoot, and scale workloads from the command line. Knowing when and how to use key flags like -n, -o, and --dry-run is essential.
- **Use a consistent workflow for debugging: get → describe → logs.** This structured approach helps surface issues faster and reduces troubleshooting time.
- **Favor declarative over imperative commands** by using YAML manifests with kubectl apply. This promotes version control, repeatability, and cleaner operations.

Kubernetes (K8s) has become the de-facto standard for orchestrating containerized applications but managing it can be overwhelming without the right tools. At the center of every Kubernetes workflow is **kubectl**, the command-line utility that lets you interact with clusters, deploy applications, inspect resources, and troubleshoot issues.

This cheat sheet is your quick-reference guide to the most useful kubectl commands, organized by category and paired with examples. Whether you’re just getting started or looking for advanced tricks, this resource will help you master Kubernetes faster. 

**Pro tip:** Already comfortable with the basics? Jump ahead to the [Power User Commands](https://www.splunk.com/en_us/blog/learn/kubernetes-commands-cheat-sheet.html#commands).

## Kubernetes at a glance: key concepts

Before diving into commands, it helps to understand [the core K8s building blocks](https://www.splunk.com/en_us/blog/learn/kubernetes-architecture.html) you’ll be working with:

- **Pods** are the smallest deployable units in Kubernetes.
- **Deployments** manage sets of pods and apply declarative updates.
- **Services** expose your applications internally or externally.
- **Namespaces** provide logical isolation of workloads and resources by creating virtual clusters within a larger physical cluster.
- **Nodes** are worker machines where workloads run.
- **Clusters** refer to collections of nodes.
- **Contexts** define environments (like prod, or staging) and let you easily switch between them.
- **YAML** is the primary format for defining Kubernetes objects.

With these concepts in mind, let’s move through kubectl commands from **basic inspection** to **advanced operations**.

### Before you dive in

Make sure kubectl is installed and your kubeconfig files are configured for your cluster. If you’re not sure, [follow the official installation guide](https://kubernetes.io/docs/tasks/tools/).  
  
Next, [learn how to set up “Vanilla” Kubernetes](https://www.splunk.com/en_us/blog/learn/kubernetes-vanilla-setup.html) — that’s the nickname for Kubernetes outside a managed service like those provided by a cloud provider).

## Inspecting and understanding your cluster

Use these commands to quickly list and describe what's running in your cluster.

|Command|What it does|Example|
|---|---|---|
|**kubectl get pods**|List all pods in current namespace|kubectl get pods|
|**kubectl get pods -n**|List pods in a specific namespace|kubectl get pods -n kube-system|
|**kubectl get services**|List all services|kubectl get services|
|**kubectl get deployments**|List all Deployments|kubectl get deployments|
|**kubectl get nodes**|List all nodes in the cluster|kubectl get nodes|
|**kubectl get all**|List all resources in namespace|kubectl get all|
|**kubectl describe pod**|Detailed info about a pod|kubectl describe pod nginx-pod|
|**kubectl describe service**|Detailed info about a service|kubectl describe service my-service|
|**kubectl describe deployment**|Detailed info about a Deployment|kubectl describe deployment web|
|**kubectl describe node**|Detailed info about a node|kubectl describe node worker-1|
|**kubectl get pods -o wide**|Show pods with additional info: IPs, node assignments, pod status, etc.|kubectl get pods -o wide|

## Deploying and managing applications

These commands let you create, update, and scale workloads in Kubernetes.

|Command|What it does|Example|
|---|---|---|
|**kubectl apply -f**|Create/update resources from YAML|kubectl apply -f app.yaml|
|**kubectl create -f**|Create resources|kubectl create -f app.yaml|
|**kubectl delete -f**|Delete resources|kubectl delete -f app.yaml|
|**kubectl delete pod**|Delete a specific pod|kubectl delete pod nginx-pod|
|**kubectl delete service**|Delete a specific service|kubectl delete service my-service|
|**kubectl delete deployment**|Delete a specific Deployment|kubectl delete deployment web|
|**kubectl scale deployment --replicas=N**|Scale replicas|kubectl scale deployment web --replicas=5|
|**kubectl rollout status deployment/**|Check rollout status of a Deployment|kubectl rollout status deployment/web|
|**kubectl rollout undo deployment/**|Roll back a Deployment|kubectl rollout undo deployment/web|

## Debugging and troubleshooting

When troubleshooting pod issues, begin by reviewing events to catch any error messages or warnings early — events firing that show errors is often a good place to start investigating. 

After that, follow a systematic workflow: get → describe → logs. This approach helps identify problems quickly before deeper inspection.

When pods fail to start or restart repeatedly, you'll often see states like ImagePullBackOff (image can't be pulled) or CrashLoopBackOff (container keeps crashing). Use kubectl describe pod <pod> to determine the pod state and kubectl logs <pod> to diagnose the root cause.

### Logs & exec

|Command|What it does|Example|
|---|---|---|
|**kubectl logs**|Show pod logs|kubectl logs nginx-pod|
|**kubectl logs -f**|Stream pod logs|kubectl logs -f api-pod|
|**kubectl logs -c**|Show logs from a specific container|kubectl logs mypod -c sidecar|
|**kubectl logs --previous**|Show logs from a previous container instance|kubectl logs mypod --previous|
|**kubectl exec -it -- /bin/bash**|Open shell inside container|kubectl exec -it mypod -- /bin/bash|
|**kubectl exec -it --**|Run a command inside a container|kubectl exec -it mypod -- curl localhost:8080|
|**kubectl cp :/remote/file ./local**|Copy files to/from pod|(From a pod): kubectl cp mypod:/var/log/app.log ./app.log|
|**kubectl port-forward pod/ :**|Forward a local port to a pod (The example makes port 80 on mypod available on port 8080 of the local machine.)|kubectl port-forward pod/mypod 8080:80|

### Resource usage

|Command|What it does|Example|
|---|---|---|
|**kubectl top nodes**|Show node CPU/memory|kubectl top nodes|
|**kubectl top pods**|Show pod CPU/memory|kubectl top pods|

### Networking checks

For deeper debugging, you can run common tools like **ping**, **curl**, or **nslookup** inside a pod using kubectl exec. This helps verify connectivity, DNS resolution, and service reachability directly from within the cluster.

|Command|What it does|Example|
|---|---|---|
|**kubectl get endpoints**|Show service endpoints|kubectl get endpoints web-svc|
|**kubectl get ingress**|List ingress rules|kubectl get ingress|
|**kubectl describe ingress**|Detailed ingress info|kubectl describe ingress app-ingress|
|**kubectl get networkpolicies**|List network policies|kubectl get networkpolicies|

## Advanced operations: storage, configs & rollouts

Once you're comfortable with the basics, these commands give you more fine-grained control.

### Storage

|Command|What it does|Example|
|---|---|---|
|**kubectl get pv**|List Persistent Volumes|kubectl get pv|
|**kubectl get pvc**|List Persistent Volume Claims|kubectl get pvc|
|**kubectl get sc**|List Storage Classes|kubectl get sc|
|**kubectl describe pv**|Detailed info about a PV|kubectl describe pv my-pv|
|**kubectl describe pvc**|Detailed info about a PVC|kubectl describe pvc my-claim|
|**kubectl describe sc**|Describe a storage class|kubectl describe sc standard|

### Configs & secrets

|Command|What it does|Example|
|---|---|---|
|**kubectl get configmap**|Get a ConfigMap|kubectl get configmap app-config|
|**kubectl describe configmap**|Show details of a ConfigMap|kubectl describe configmap app-config|
|**kubectl get secret**|Get a Secret|kubectl get secret db-secret|
|**kubectl describe secret**|Show secret details|kubectl describe secret db-secret|

### Rollouts

|Command|What it does|Example|
|---|---|---|
|**kubectl rollout history deployment/**|View rollout history|kubectl rollout history deployment/web|
|**kubectl rollout pause deployment/**|Pause rollout|kubectl rollout pause deployment/web|
|**kubectl rollout resume deployment/**|Resume rollout|kubectl rollout resume deployment/web|
|**kubectl set image deployment/ =**|Update container image|kubectl set image deployment/web app=nginx:1.19|
|**kubectl edit /**|Edit a live resource definition|kubectl edit deployment/web|

## Power user commands: going beyond the basics

Once you've mastered the essentials, these commands will give you deeper visibility and finer-grained control of your cluster.

### More granular inspection

|Command|What it does|Example|
|---|---|---|
|**kubectl get all -A**|List all resources across _all_ namespaces|kubectl get all -A|
|**kubectl get events -A --sort-by='.lastTimestamp'**|View recent cluster-wide events|kubectl get events -A --sort-by='.lastTimestamp'|
|**kubectl get pods --show-labels**|Show pods with their labels|kubectl get pods --show-labels|
|**kubectl get -o yaml**|Output resource as YAML|kubectl get pod nginx -o yaml|
|**kubectl get -o json**|Output resource as JSON|kubectl get svc my-service -o json|

### Advanced logs & exec

|Command|What it does|Example|
|---|---|---|
|**kubectl logs --since=**|Show logs since a given time|kubectl logs --since=1h nginx-pod|
|**kubectl logs --tail=**|Show last N log lines|kubectl logs --tail=50 api-pod|
|**kubectl exec -it --**|Run a specific command inside a pod|kubectl exec -it mypod -- curl localhost:8080|

### Cluster & context management

|Command|What it does|Example|
|---|---|---|
|**kubectl cluster-info**|Show cluster master & services info|kubectl cluster-info|
|**kubectl config current-context**|Show current context|kubectl config current-context|
|**kubectl config get-contexts**|List all contexts|kubectl config get-contexts|
|**kubectl config use-context**|Switch to another context|kubectl config use-context staging|
|**kubectl version**|Show client & server version|kubectl version|
|**kubectl explain**|Show resource definition docs|kubectl explain pod|

## Beyond kubectl: bonus K8s ecosystem tools

- Package manager for Kubernetes: helm 
- Terminal UI for clusters: k9s
- Quickly switch between clusters (contexts): kubectx
- Quickly switch between namespaces: kubens
- Create local Kubernetes clusters for dev/test: minikube / kind

## Best practices for stable Kubernetes operations

Kubernetes is powerful, but it can quickly get messy without guardrails. These practices help ensure efficiency, reliability, and stability in your clusters.

### Efficiency tips and productivity hacks

- **Autocompletion**:  source <(kubectl completion bash)
- **Aliases**: alias k=kubectl
- **Dry-run flag:** Test changes without applying: kubectl apply -f app.yaml --dry-run=client
- **Namespaces:** Always check the namespace (-n flag)
- **Labels & selectors:** Filter resources with -l key=value
- **Declarative over imperative:** Prefer YAML manifests (apply -f)

### Operational best practices

**Define resource requests and limits** to prevent noisy-neighbor issues. Misconfigured or missing resource constraints are among the top causes of Kubernetes errors. You can check resource requests and limits for your pods using this command:

kubectl get pods -n <namespace> -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].resources.requests.cpu}{"\t"}{.spec.containers[*].resources.limits.cpu}{""}{end}'

This lists each pod's name along with its CPU requests and limits, helping identify pods without proper resource constraints. For example:

my-app-pod-1    500m    1
my-app-pod-2    250m    500m

Setting appropriate CPU and memory requests ensures pods get guaranteed resources, while limits prevent excessive consumption, avoiding cluster resource contention and performance issues.