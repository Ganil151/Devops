# Advanced Level: Compliance & Policy

In enterprise environments, you cannot rely on trust alone. You need to enforce policies (what images can run, what ports can open) and audit all actions.

## 🎯 Learning Objectives
- Understand **Open Policy Agent (OPA)** and **Gatekeeper**.
- Enforce **Pod Security Standards**.
- Enable and analyze **Audit Logs**.

## 1. Policy Enforcement (OPA/Gatekeeper)
Kubernetes allows you to write "Policy as Code".
**OPA Gatekeeper** is an admission controller that validates requests against policies defined in Rego language.

### Use Cases
- **Registry Whitelist**: Only allow images from `habor.mycorp.com`.
- **Label Governance**: All pods must have a `cost-center` label.
- **Resource Limits**: All containers must have memory limits set.

### Example Constraint
```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: ns-must-have-owner
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Namespace"]
  parameters:
    labels: ["owner"]
```

## 2. Pod Security Standards (PSS)
Replaces the deprecated Pod Security Policies (PSP).
It defines three levels of security:
1. **Privileged**: Unrestricted (e.g., for system drivers).
2. **Baseline**: Minimally restrictive (prevents known privilege escalations).
3. **Restricted**: Heavily restricted (best practices).

Enforced via namespace labels:
```bash
kubectl label namespace my-app pod-security.kubernetes.io/enforce=restricted
```

## 3. Audit Logging
Kubernetes can record every API request (who, what, when, where).
- configured via flags on the `kube-apiserver` (`--audit-policy-file`, `--audit-log-path`).
- Critical for compliance (SOC2, PCI-DSS).

[Back to Advanced Index](../README.md)
