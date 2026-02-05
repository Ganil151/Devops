# 🛠️ Container & K8s Challenges

## Challenge 1: The Image Pruner
**Objective**: Clean up dangling images.
1.  Connect using `docker.from_env()`.
2.  List images: `client.images.list()`.
3.  Filter images where tags is empty or `<none>`.
4.  Remove them using `client.images.remove(id)`.
5.  Handle `APIError` (e.g., image in use).

## Challenge 2: Pod Lister (Kubernetes)
**Objective**: List Pods in "default" namespace.
1.  Install `kubernetes` pip package.
2.  Load config: `config.load_kube_config()`.
3.  Create API client: `client.CoreV1Api()`.
4.  Call `list_namespaced_pod("default")`.
5.  Print Name and IP of each pod.

## Challenge 3: Restart Failed Pods
**Objective**: Delete pods in 'Error' state (Simulating a restart).
1.  Iterate pods.
2.  Check `pod.status.phase`.
3.  If "Failed", call `delete_namespaced_pod(name, namespace)`.
4.  Log the action.
