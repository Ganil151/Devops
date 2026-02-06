# Missing Sections for Kubectl Basics

This file contains the high-fidelity enhancements for the Kubectl module.

---

## 🚀 Pro-Level Productivity: The Kubectl "God Mode"

### 1. The Power of JSONPath
Stop scrolling through massive YAML files. Use JSONPath to extract exactly what you need.

**Scenario:** Get the names of all images currently running in the `production` namespace.
```bash
kubectl get pods -n production -o jsonpath='{.items[*].spec.containers[*].image}'
```

**Scenario:** Get the IP addresses of all nodes.
```bash
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'
```

### 2. Custom Columns for Reporting
Create your own terminal views.

```bash
kubectl get pods -o custom-columns="POD_NAME:.metadata.name,RESTARTS:.status.containerStatuses[0].restartCount,NODE:.spec.nodeName"
```

---

## 🛠️ Essential "Day 2" Aliases
Add these to your `.bashrc` or `.zshrc` to save hours of typing.

```bash
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kx='kubectl exec -it'
alias kl='kubectl logs'
alias kpf='kubectl port-forward'
alias kn='kubectl config set-context --current --namespace' # Switch namespace quickly!
```

**The "Context Swapper" (using `fzf`):**
```bash
alias kctx='kubectl config get-contexts -o name | fzf | xargs kubectl config use-context'
```

---

## 📖 Real-World DevOps Story: "The Accidental Purge"

**The Scenario:** A junior engineer wanted to delete all pods in their local development namespace. They intended to run `kubectl delete pods --all`. However, they were accidentally in the `production` context and forgot to specify the resource type. They ran a variation that targeted the entire namespace.

**The Result:** Every resource in the namespace—Deployments, Services, ConfigMaps, Secrets—was deleted in seconds. Because they didn't have **GitOps** (ArgoCD/Flux) or a solid backup, it took 6 hours to manually reconstruct the environment from old manifests.

**The Lesson:** 
- **Always** use a prompt that shows your current context/namespace (e.g., Starship or Oh My Zsh).
- **Never** use `--all` in production without a second pair of eyes.
- Use tools like `kubectx` and `kubens` to avoid context confusion.

---

## 👨‍💻 Interview Preparation (CLI Master)

1. **Q: What is the difference between `kubectl apply` and `kubectl create`?**
   *   *A: `create` is imperative; it creates a new resource and fails if it already exists. `apply` is declarative; it creates or updates the resource to match the file (using the `last-applied-configuration` annotation).*

2. **Q: How do you view logs of a container that crashed 10 minutes ago?**
   *   *A: Use `kubectl logs --previous <pod-name>`. This retrieves the logs from the container's previous instantiation.*

3. **Q: How do you "debug" a pod that has no shell (e.g., Distroless images)?**
   *   *A: Use `kubectl debug <pod-name> -it --image=busybox --copy-to=debug-pod`. This creates a copy of the pod with an ephemeral troubleshooting container.*

4. **Q: How can you see the exact API request kubectl sends to the server?**
   *   *A: Increase the verbosity level: `kubectl get pods -v=8` or `-v=9`.*

---

## 🧠 Knowledge Check

1. Which command switches your active namespace to `kube-system`? 
2. How do you force a restart of all pods in a Deployment? (`kubectl rollout restart deployment <name>`)
3. What flag allows you to test a command without actually changing anything? (`--dry-run=client`)
