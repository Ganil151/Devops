# K8s Networking & Config Challenges 🌐

Master the service discovery and internal cluster communication patterns.

---

## 🏆 Challenge 01: Service Discovery
**Objective**: Expose your application to the cluster.

1.  **Requirement**: Deploy an App with 3 replicas.
2.  **Task**: Create a **ClusterIP** Service named `app-service`.
3.  **Verification**: Use `kubectl exec` into a temporary busybox pod and run `wget -qO- app-service`.
4.  **Discovery**: How does Kubernetes DNS resolve the service name to an IP?

---

## 🏆 Challenge 02: External Access (LoadBalancer/NodePort)
**Objective**: Allow users to access the app from outside the cluster.

1.  **Task**: Convert your `ClusterIP` to a **NodePort**.
2.  **Logic**: Map the service to NodePort `30080`.
3.  **Advanced**: If you are on AWS/GCP, create a **LoadBalancer** service and observe the External IP creation.

---

## 🏆 Challenge 03: Configuration via ConfigMaps
**Objective**: Decouple environment configuration from the image.

1.  **Requirement**: Create a **ConfigMap** called `web-config` containing `BG_COLOR=blue`.
2.  **Task**: Inject this ConfigMap into your pod as an environment variable.
3.  **Verification**: Log into the container and run `env | grep BG`.

---

## 📁 Solutions
Service manifests and ConfigMap templates are in the `Boilerplates/` directory.
