# ArgoCD Project Setup Instructions

This document provides step-by-step instructions for setting up Helm and ArgoCD in a Minikube environment.

## Step 1: Download the Helm Installation Script

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
```

This command downloads the Helm installation script from the official Helm GitHub repository. The flags used are:
- `-f`: Fail silently on server errors
- `-s`: Silent mode (no progress meter)
- `-S`: Show error even when -s is used
- `-L`: Follow redirects
- `-o get_helm.sh`: Save output to file named `get_helm.sh`

## Step 2: Make the Script Executable

```bash
chmod 700 get_helm.sh
```

This sets the file permissions to allow the owner (you) to read, write, and execute the script, while denying permissions to group and others.

## Step 3: Run the Helm Installation Script

```bash
./get_helm.sh
```

This executes the downloaded script to install Helm. The output indicates that Helm v4.0.4 is already the latest version installed.

## Step 4: Add the ArgoCD Helm Repository

```bash
helm repo add argo https://argoproj.github.io/argo-helm
```

This adds the ArgoCD Helm chart repository to your local Helm configuration. The repository contains Helm charts for deploying ArgoCD.

Output: `"argo" has been added to your repositories`

## Step 5: Check Minikube Status

```bash
minikube status
```

This command checks the status of your Minikube cluster. The output shows:
- minikube: Running
- Control Plane: Running
- kubelet: Running
- apiserver: Running
- kubeconfig: Configured

## Step 6: Verify Kubernetes Nodes

```bash
kubectl get nodes
```

This Kubernetes command lists all nodes in the cluster. The output shows:
- Node name: minikube
- Status: Ready
- Roles: control-plane
- Age: 67 minutes
- Version: v1.34.0

## Step 7: Update Helm Repositories

```bash
helm repo update
```

This updates all Helm repositories to fetch the latest chart information. The output indicates successful update from the "argo" repository.

## Step 8: Search for ArgoCD Charts

```bash
helm search repo argocd
```

This command searches for Helm charts in the added repositories that match the keyword "argocd". It will list available ArgoCD-related charts from the "argo" repository, including their names, versions, and descriptions. This helps you identify the correct chart name for installation.

## Step 9: Export Default Values for ArgoCD Chart

```bash
helm show values argo/argo-cd --version 3.35.4 > argocd-defaults.yaml
```

This command retrieves the default configuration values for the ArgoCD Helm chart at version 3.35.4 and saves them to a file named `argocd-defaults.yaml`. The `helm show values` command displays the default values.yaml content of a chart, and the `--version` flag specifies the exact chart version. The `>` operator redirects the output to create the YAML file, which can then be edited to customize your ArgoCD installation.

## Step 10: Create ArgoCD Namespace

```bash
kubectl create namespace argocd
```

This Kubernetes command creates the `argocd` namespace where ArgoCD will be installed. Creating the namespace explicitly ensures it's available before deploying the Helm chart.

## Step 11: Install ArgoCD

```bash
helm install argocd argo/argo-cd \
  --namespace argocd \
  --version 3.35.4
```

This Helm command installs ArgoCD using the chart from the added repository. It deploys ArgoCD version 3.35.4 into the `argocd` namespace. The backslash allows the command to span multiple lines for readability.

## Step 12: Check ArgoCD Helm Release Status

```bash
helm status argocd -n argocd
```

This command displays the status of the deployed ArgoCD Helm release, including information about the release version, deployment status, resources created, and any additional notes provided by the chart. The `-n argocd` flag specifies the namespace where ArgoCD is installed, allowing you to verify that the installation was successful and check for any issues.

## Step 13: List All Helm Releases

```bash
helm list -A
```

This command lists all Helm releases deployed in the cluster across all namespaces. The `-A` flag (short for `--all-namespaces`) ensures that releases from every namespace are included in the output, providing a comprehensive view of all installed Helm charts and their statuses.

## Step 14: List Pods in ArgoCD Namespace

```bash
kubectl get pods -n argocd
```

This Kubernetes command lists all pods in the `argocd` namespace. It shows the pod names, ready status, status, restarts, and age. This helps verify that ArgoCD components (like the server, repo-server, and application controller) are running properly.

## Step 15: List Secrets in ArgoCD Namespace

```bash
kubectl get secrets -n argocd
```

This Kubernetes command lists all secrets in the `argocd` namespace. Secrets in ArgoCD typically include credentials for repositories, admin passwords, and other sensitive configuration data. Use this to check that necessary secrets are present.

## Step 15: Get and Decode Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

This command retrieves the base64-encoded admin password directly from the ArgoCD initial admin secret in the `argocd` namespace and decodes it to plain text in one step. The `kubectl get secret` command uses `jsonpath` to extract the `password` field from the secret's data, which is then piped to `base64 -d` for decoding, revealing the plain text admin password that can be used to log into the ArgoCD web interface.

## Step 16: Port Forward ArgoCD Server

```bash
kubectl port-forward service/argocd-server -n argocd 8080:443
```

This Kubernetes command forwards local port 8080 to the ArgoCD server's port 443 in the `argocd` namespace. This allows you to access the ArgoCD web UI by navigating to `https://localhost:8080` in your browser. The port forwarding runs in the foreground, so you'll need to keep this terminal session open while accessing the UI.

## Step 17: Pull Nginx Docker Image

```bash
docker pull nginx:1.29.4
```

This Docker command pulls the Nginx web server image version 1.29.4 from Docker Hub. This image can be used for deploying a sample web application or as a base for creating custom web services in your Kubernetes cluster.

## Step 18: List Docker Images

```bash
docker images
```

This Docker command lists all Docker images that are currently stored on your local system. It displays information such as repository name, tag, image ID, creation date, and size for each image, helping you verify that the Nginx image was successfully pulled.

## Step 19: Tag the Nginx Image

```bash
docker tag nginx:1.29.4 ganil151/nginx:v0.1.0
```

This Docker command creates a new tag for the existing Nginx image. It tags the `nginx:1.29.4` image with the name `ganil151/nginx:v0.1.0`, which includes your username/organization and a version tag. This is typically done before pushing the image to a Docker registry like Docker Hub.

## Step 20: Push the Tagged Image

```bash
docker push ganil151/nginx:v0.1.0
```

This Docker command uploads the tagged Nginx image to Docker Hub (or another configured registry). It pushes the `ganil151/nginx:v0.1.0` image to your repository, making it available for others to pull or for use in Kubernetes deployments managed by ArgoCD.

## Step 21: Create ArgoCD Lesson Directory Structure

```bash
mkdir -p argoCD-Lesson-p1/environments/staging/my-app
```

This command creates the directory structure for the ArgoCD lesson. The `argoCD-Lesson-p1` directory will contain the application manifests, and `environments/staging/my-app` is a subdirectory for organizing the specific application components.

## Step 22: Create Namespace Manifest

Create a file named `0.namespaces.yaml` in the `argoCD-Lesson-p1/environments/staging/my-app/` directory with the following content:

```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: prod
```

This YAML file defines a Kubernetes namespace named `prod`. The `0` prefix in the filename ensures it gets applied first when using ArgoCD, creating the namespace before other resources that depend on it.

## Step 23: Create Deployment Manifest

Create a file named `deployment.yaml` in the `argoCD-Lesson-p1/environments/staging/my-app/` directory with the following content:

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: prod
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: nginx
        image: ganil151/nginx:v0.1.0
        ports:
        - containerPort: 80
```

This YAML file defines a Kubernetes Deployment for the Nginx application. It creates one replica of the pod running the custom Nginx image in the `prod` namespace, exposing port 80 for web traffic.

## Step 24: Generate Base64 Encoded Docker Config

```bash
echo '{"auths":{"https://index.docker.io/v1/":{"username":"ganil151","password":"GanilDocker3773","email":"ganilbatistyan@gmail.com"}}}' | base64 -w 0
```

This command generates a base64 encoded Docker configuration JSON that contains your Docker Hub credentials. The output will be used in the secret manifest to allow Kubernetes to pull private images from Docker Hub. The `-w 0` flag ensures the output is on a single line without line breaks.

## Step 25: Create Docker Registry Secret Manifest

Create a file named `secret.yaml` in the `argoCD-Lesson-p1/environments/staging/my-app/` directory with the following content (replace `<base64-output>` with the output from Step 24):

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: dockerconfigjson
  namespace: prod
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <base64-output>
```

This YAML file defines a Kubernetes Secret of type `dockerconfigjson` that contains the base64 encoded Docker configuration. This secret will be referenced by the deployment's `imagePullSecrets` to authenticate with Docker Hub when pulling the private `ganil151/nginx-private:v0.1.1` image.

## Step 26: Alternative - Create Secret Directly with kubectl

```bash
kubectl create secret docker-registry dockerconfigjson \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=ganil151 \
  --docker-password=GanilDocker3773 \
  --docker-email=ganilbatistyan@gmail.com \
  -n prod
```

This `kubectl` command creates the Docker registry secret directly in the Kubernetes cluster. This is an alternative to creating the secret manifest file. The command creates a secret with your Docker Hub credentials that can be used to pull private images. Note: This approach creates the secret imperatively rather than through GitOps, so it's less preferred when using ArgoCD.

## Step 27: Commit and Push to GitHub

```bash
git add .
git commit -m "Add nginx deployment with docker registry secret"
git push origin main
```

This sequence of Git commands stages all changes (including the new manifests), commits them with a descriptive message, and pushes the commit to the `main` branch on GitHub. This makes the application manifests available in the repository for ArgoCD to monitor and deploy.

## Troubleshooting

This section covers common issues encountered during ArgoCD deployment and their solutions.

### Issue 1: Pod Status Shows "ImagePullBackOff" or "ErrImagePull"

**Symptoms:**
- Pods remain in `Pending` or `ImagePullBackOff` status
- Error messages like "Failed to pull image" or "manifest unknown"

**Possible Causes & Solutions:**

1. **Image doesn't exist in registry:**
   ```bash
   # Check if image exists locally
   docker images
   
   # Tag and push the image if missing
   docker tag <local-image>:<tag> <registry>/<repo>:<tag>
   docker push <registry>/<repo>:<tag>
   ```

2. **Incorrect image name in deployment:**
   - Verify the image name in `deployment.yaml` matches what's pushed to the registry
   - Check for typos in repository name, image name, or tag

3. **Network/connectivity issues:**
   ```bash
   # Test registry connectivity
   docker pull <image-name>
   ```

### Issue 2: "Unauthorized: Incorrect Username or Password" Error

**Symptoms:**
- Image pull fails with authentication errors
- Docker Hub rate limiting messages

**Solutions:**

1. **Verify Docker Hub credentials:**
   ```bash
   # Test login manually
   docker login --username <username>
   # Enter password when prompted
   ```

2. **Create/update the image pull secret:**
   ```bash
   # Delete old secret if exists
   kubectl delete secret dockerconfigjson -n <namespace>
   
   # Create new secret with correct credentials
   kubectl create secret docker-registry dockerconfigjson \
     --docker-server=https://index.docker.io/v1/ \
     --docker-username=<username> \
     --docker-password=<password> \
     --docker-email=<email> \
     -n <namespace>
   ```

3. **Check secret format:**
   ```bash
   # Verify secret contents
   kubectl get secret dockerconfigjson -n <namespace> -o yaml
   ```

### Issue 3: ArgoCD Application Shows "Degraded" or "Progressing" Health

**Symptoms:**
- ArgoCD UI shows application as unhealthy
- Sync status shows errors

**Solutions:**

1. **Check pod status:**
   ```bash
   kubectl get pods -n <application-namespace>
   kubectl describe pod <pod-name> -n <application-namespace>
   ```

2. **Check ArgoCD application events:**
   ```bash
   kubectl get applications -n argocd
   kubectl describe application <app-name> -n argocd
   ```

3. **Force sync the application:**
   ```bash
   # Using kubectl (if argocd CLI not available)
   kubectl rollout restart deployment/<deployment-name> -n <namespace>
   ```

4. **Verify manifests are committed and pushed:**
   ```bash
   git status
   git log --oneline -5
   ```

### Issue 4: Secret Creation Issues

**Symptoms:**
- Secret exists but authentication still fails
- Base64 decoding errors

**Solutions:**

1. **Use kubectl create secret (recommended):**
   ```bash
   kubectl create secret docker-registry <secret-name> \
     --docker-server=<registry-url> \
     --docker-username=<username> \
     --docker-password=<password> \
     --docker-email=<email> \
     -n <namespace>
   ```

2. **Manual secret creation (alternative):**
   ```bash
   # Generate base64 encoded config
   echo '{"auths":{"<registry>":{"username":"<user>","password":"<pass>","email":"<email>"}}}' | base64 -w 0
   
   # Use the output in secret.yaml
   ```

3. **Verify secret type:**
   - Use `kubernetes.io/dockerconfigjson` for docker config format
   - Use `kubernetes.io/docker-registry` for individual registry credentials

### Issue 5: Deployment References Wrong Image

**Symptoms:**
- Deployment uses `ganil151/nginx-private:v0.1.1` but only `ganil151/nginx:v0.1.0` exists

**Solutions:**

1. **Update deployment.yaml:**
   ```yaml
   spec:
     containers:
     - name: nginx
       image: ganil151/nginx:v0.1.0  # Use correct image
   ```

2. **Or push the correct private image:**
   ```bash
   docker tag ganil151/nginx:v0.1.0 ganil151/nginx-private:v0.1.1
   docker push ganil151/nginx-private:v0.1.1
   ```

### General Debugging Commands

```bash
# Check all resources in namespace
kubectl get all -n <namespace>

# Check events for recent issues
kubectl get events -n <namespace> --sort-by=.metadata.creationTimestamp

# Check ArgoCD application details
kubectl get application <app-name> -n argocd -o yaml

# View pod logs
kubectl logs <pod-name> -n <namespace>

# Check service accounts and permissions
kubectl get serviceaccounts -n <namespace>
```

## Step 28: Update ArgoCD Application with Automated Sync Policy

Update the `application.yaml` file in the `argoCD-Lesson-p2/` directory to include the destination namespace:

```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/Ganil151/Argo-Project.git
    targetRevision: HEAD
    path: argoCD-Lesson-p1/environments/staging/my-app
  destination:
    server: https://kubernetes.default.svc
    namespace: prod
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
      - Validate=true
      - CreateNamespace=true
      - PrunePropagationPolicy=Foreground
      - PruneLast=true
```

**Key Addition:**
- `namespace: prod` in the destination section ensures the application deploys to the correct namespace

This configuration enables automated synchronization with the following features:

- **Automated Sync**: ArgoCD will automatically sync the application when changes are detected in the Git repository
- **Prune**: Automatically remove resources that are no longer defined in the manifests
- **Self Heal**: Automatically correct any drift between the desired state (Git) and actual state (cluster)
- **Allow Empty**: Prevents accidental deletion of all resources
- **Sync Options**:
  - `Validate=true`: Validate manifests before applying
  - `CreateNamespace=true`: Allow ArgoCD to create namespaces if needed
  - `PrunePropagationPolicy=Foreground`: Delete dependent resources before the main resource
  - `PruneLast=true`: Prune resources after all other operations are complete

## Step 29: Commit and Push Application Updates

```bash
git add .
git commit -m "Add automated sync policy to ArgoCD application"
git push origin main
```

This updates the ArgoCD application configuration to enable automated GitOps workflows.

## Step 30: Apply the Updated ArgoCD Application

```bash
kubectl apply -f argoCD-Lesson-p2/application.yaml
```

This command applies the updated ArgoCD Application manifest to the cluster. The application will now:

- Deploy to the `prod` namespace as specified
- Enable automated synchronization with Git repository changes
- Automatically prune removed resources
- Self-heal any configuration drift
- Validate manifests before applying changes

**Note**: If you see a warning about finalizers, update the finalizer name to include a path: `resources-finalizer.argocd.argoproj.io/finalizers`

## Next Steps

Now that ArgoCD is installed, you can access the ArgoCD web UI, retrieve the admin password, and start creating applications. You can also explore creating GitOps workflows by deploying the sample application manifests created in the previous steps.

Make sure your Minikube cluster is running and kubectl is configured to interact with it.

# Stopped lesson 
https://youtu.be/zGndgdGa1Tc?t=890  