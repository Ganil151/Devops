# ArgoCD Troubleshooting

Common issues, debugging techniques, and resolution strategies for ArgoCD operations.

## Common Issues

### Sync Failures

#### Out of Sync Applications
```bash
# Check application status
argocd app get myapp

# View sync differences
argocd app diff myapp

# Force sync
argocd app sync myapp --force

# Refresh application
argocd app get myapp --refresh
```

#### Resource Conflicts
```bash
# Check for resource conflicts
kubectl get events -n production --sort-by='.lastTimestamp'

# View application events
argocd app get myapp -o yaml | grep -A 10 "conditions:"

# Manual resource cleanup
kubectl delete deployment myapp -n production
argocd app sync myapp
```

### Authentication Issues

#### OIDC Login Problems
```bash
# Check OIDC configuration
kubectl get configmap argocd-server-config -n argocd -o yaml

# Verify OIDC secret
kubectl get secret argocd-secret -n argocd -o yaml

# Test OIDC endpoint
curl -k https://auth.example.com/.well-known/openid_configuration
```

#### RBAC Permission Denied
```bash
# Check user groups
argocd account get --account myuser

# Verify RBAC policy
kubectl get configmap argocd-rbac-cm -n argocd -o yaml

# Test permissions
argocd app list --project myproject
```

## Debugging Commands

### Application Debugging
```bash
# Detailed application info
argocd app get myapp -o yaml

# Application logs
kubectl logs -n argocd deployment/argocd-application-controller

# Sync operation logs
argocd app logs myapp --follow

# Resource tree view
argocd app tree myapp
```

### Server Debugging
```bash
# ArgoCD server logs
kubectl logs -n argocd deployment/argocd-server

# Repository server logs
kubectl logs -n argocd deployment/argocd-repo-server

# Application controller logs
kubectl logs -n argocd deployment/argocd-application-controller
```

## Performance Issues

### Slow Sync Operations
```bash
# Check resource usage
kubectl top pods -n argocd

# Increase parallelism
kubectl patch configmap argocd-cmd-params-cm -n argocd --patch '
data:
  application.operation.processors: "20"
  application.status.processors: "20"
'

# Optimize Git operations
kubectl patch configmap argocd-cmd-params-cm -n argocd --patch '
data:
  reposerver.parallelism.limit: "10"
'
```

### Memory Issues
```bash
# Check memory usage
kubectl describe pod argocd-server-xxx -n argocd

# Increase memory limits
kubectl patch deployment argocd-server -n argocd --patch '
spec:
  template:
    spec:
      containers:
      - name: argocd-server
        resources:
          limits:
            memory: 512Mi
          requests:
            memory: 256Mi
'
```

## Recovery Procedures

### Application Recovery
```bash
# Reset application to last known good state
argocd app rollback myapp

# Delete and recreate application
argocd app delete myapp
argocd app create myapp --repo https://github.com/user/repo --path k8s --dest-server https://kubernetes.default.svc --dest-namespace production

# Force refresh from Git
argocd app get myapp --hard-refresh
```

### Cluster Recovery
```bash
# Re-add cluster
argocd cluster add kubernetes-cluster --name production

# Update cluster credentials
argocd cluster set kubernetes-cluster --kubeconfig /path/to/kubeconfig

# Test cluster connectivity
argocd cluster list
```

This comprehensive troubleshooting guide helps resolve common ArgoCD operational issues.