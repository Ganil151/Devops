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

## Step 10: Check ArgoCD Helm Release Status

```bash
helm status argocd -n argocd
```

This command displays the status of the deployed ArgoCD Helm release, including information about the release version, deployment status, resources created, and any additional notes provided by the chart. The `-n argocd` flag specifies the namespace where ArgoCD is installed, allowing you to verify that the installation was successful and check for any issues.

## Step 11: List All Helm Releases

```bash
helm list -A
```

This command lists all Helm releases deployed in the cluster across all namespaces. The `-A` flag (short for `--all-namespaces`) ensures that releases from every namespace are included in the output, providing a comprehensive view of all installed Helm charts and their statuses.

## Step 12: List Pods in ArgoCD Namespace

```bash
kubectl get pods -n argocd
```

This Kubernetes command lists all pods in the `argocd` namespace. It shows the pod names, ready status, status, restarts, and age. This helps verify that ArgoCD components (like the server, repo-server, and application controller) are running properly.

## Step 13: List Secrets in ArgoCD Namespace

```bash
kubectl get secrets -n argocd
```

This Kubernetes command lists all secrets in the `argocd` namespace. Secrets in ArgoCD typically include credentials for repositories, admin passwords, and other sensitive configuration data. Use this to check that necessary secrets are present.

## Step 14: List Secrets in ArgoCD Namespace (Alternative)

```bash
kubectl get secrets -n argocd
```

This is the same command as Step 13, providing an alternative way to list secrets in the ArgoCD namespace. It can be used to verify secret creation or check for any changes in the secret list.

## Step 15: Get ArgoCD Initial Admin Secret

```bash
kubectl get secrets argocd-initial-admin-secret -o yaml -n argocd
```

This Kubernetes command retrieves the `argocd-initial-admin-secret` in YAML format from the `argocd` namespace. This secret contains the initial admin password for ArgoCD. The `-o yaml` flag outputs the secret data in YAML format, which includes the base64-encoded password that can be decoded to access the ArgoCD web UI.

## Step 16: Decode the Admin Password

```bash
echo "Qmo2Q09uelljbXllbVZpUA==" | base64 -d
```

This command decodes the base64-encoded string obtained from the ArgoCD initial admin secret. The `echo` command outputs the base64 string, which is then piped to `base64 -d` for decoding. This reveals the plain text admin password that can be used to log into the ArgoCD web interface.

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
mkdir -p agrocd-lesson-1/my-app
```

This command creates the directory structure for the ArgoCD lesson. The `agrocd-lesson-1` directory will contain the application manifests, and `my-app` is a subdirectory for organizing the specific application components.

## Step 22: Create Namespace Manifest

Create a file named `0.namespaces.yaml` in the `agrocd-lesson-1/my-app/` directory with the following content:

```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: prod
```

This YAML file defines a Kubernetes namespace named `prod`. The `0` prefix in the filename ensures it gets applied first when using ArgoCD, creating the namespace before other resources that depend on it.

## Step 23: Create Deployment Manifest

Create a file named `deployment.yaml` in the `agrocd-lesson-1/my-app/` directory with the following content:

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

## Next Steps

With Helm installed and the ArgoCD repository added, you can now proceed to install ArgoCD using Helm charts. For example:

```bash
helm install argocd argo/argo-cd
```

Make sure your Minikube cluster is running and kubectl is configured to interact with it.

# Stopped lesson https://youtu.be/zGndgdGa1Tc?t=890