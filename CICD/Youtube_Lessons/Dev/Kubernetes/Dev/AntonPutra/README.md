(Anton_Putra)[https://youtu.be/aRXg75S5DWA?list=PLiMWaCMwGJXnKY6XmeifEpjIfkWRo9v2l]

### Notes 



aws eks update-kubeconfig:
This is an AWS CLI command specifically designed to update the Kubernetes kubeconfig file.
The kubeconfig file is used by Kubernetes tools like kubectl to authenticate and interact with a Kubernetes cluster.
--region us-east-1:
Specifies the AWS region where the EKS cluster is located. In this case, the region is us-east-1 (US East, N. Virginia).
--name staging-demo:
Specifies the name of the EKS cluster. Here, the cluster name is staging-demo.
What Happens When You Run This Command?
Fetches Cluster Information:
The AWS CLI retrieves the necessary connection details for the specified EKS cluster (staging-demo) in the us-east-1 region.
Updates the kubeconfig File:
The command adds or updates the configuration for the EKS cluster in your local kubeconfig file.
On Linux/macOS, the kubeconfig file is typically located at ~/.kube/config.
On Windows, as shown in the output, it is located at C:\Users\<username>\.kube\config.
Adds a New Context:
A "context" in Kubernetes refers to a combination of:
A cluster (the EKS cluster in this case),
A user (the IAM role or user you are using to authenticate), and
A namespace (optional).
The new context is added to the kubeconfig file, allowing you to switch between multiple clusters if needed.
Authentication:
The AWS CLI uses your current AWS credentials (from the AWS CLI configuration or environment variables) to authenticate with the EKS cluster.
It ensures that you have the necessary permissions (via IAM roles/policies) to access the cluster.
```bash
$ aws eks update-kubeconfig \
> --region us-east-1 \
> --name staging-demo
Added new context arn:aws:eks:us-east-1:365269738775:cluster/staging-demo to C:\Users\ganil\.kube\config
```

aws eks update-kubeconfig:
This is an AWS CLI command specifically designed to update the Kubernetes kubeconfig file.
The kubeconfig file is used by Kubernetes tools like kubectl to authenticate and interact with a Kubernetes cluster.
--region us-east-1:
Specifies the AWS region where the EKS cluster is located. In this case, the region is us-east-1 (US East, N. Virginia).
--name staging-demo:
Specifies the name of the EKS cluster. Here, the cluster name is staging-demo.
What Happens When You Run This Command?
Fetches Cluster Information:
The AWS CLI retrieves the necessary connection details for the specified EKS cluster (staging-demo) in the us-east-1 region.
Updates the kubeconfig File:
The command adds or updates the configuration for the EKS cluster in your local kubeconfig file.
On Linux/macOS, the kubeconfig file is typically located at ~/.kube/config.
On Windows, as shown in the output, it is located at C:\Users\<username>\.kube\config.
Adds a New Context:
A "context" in Kubernetes refers to a combination of:
A cluster (the EKS cluster in this case),
A user (the IAM role or user you are using to authenticate), and
A namespace (optional).
The new context is added to the kubeconfig file, allowing you to switch between multiple clusters if needed.
Authentication:
The AWS CLI uses your current AWS credentials (from the AWS CLI configuration or environment variables) to authenticate with the EKS cluster.
It ensures that you have the necessary permissions (via IAM roles/policies) to access the cluster.
Output Explanation
```bash
Added new context arn:aws:eks:us-east-1:582169653259:cluster/staging-demo to C:\Users\ganil\.kube\config
```
Added new context:
Indicates that a new context has been successfully added to the kubeconfig file.

```bash
arn:aws:eks:us-east-1:582169653259:cluster/staging-demo:
```

This is the Amazon Resource Name (ARN) of the EKS cluster.
It uniquely identifies the cluster in AWS and includes:
The service (eks),
The region (us-east-1),
The AWS account ID (582169653259), and
The cluster name (staging-demo).
to C:\Users\ganil\.kube\config:
Specifies the location of the kubeconfig file on your system where the new context has been added.
Key Points to Note
Switching Contexts:
After running this command, you can use the following kubectl command to view all available contexts:

```bash
kubectl config get-contexts
```
To switch to the new context (e.g., staging-demo), use:

```bash
kubectl config use-context arn:aws:eks:-east-1:582169653259:cluster/staging-demo
```

IAM Permissions:
Ensure that your AWS credentials have the necessary permissions to access the EKS cluster. Typically, this requires the eks:DescribeCluster permission.
Kubernetes Access:
Once the kubeconfig file is updated, you can use kubectl commands to interact with the EKS cluster, such as:

```bash
kubectl get nodes
kubectl get pods --all-namespaces
```
Cross-Account Access:
If you're accessing an EKS cluster in another AWS account, additional IAM role mappings may be required in the aws-auth ConfigMap within the cluster.

kubectl:
This is the Kubernetes command-line tool used to interact with a Kubernetes cluster.
get nodes:
This subcommand retrieves information about all the nodes in the Kubernetes cluster.
A "node" in Kubernetes is a worker machine (physical or virtual) that runs containerized applications managed by the cluster.
Output Explanation
```bash
NAME                         STATUS   ROLES    AGE   VERSION
ip-10-0-24-70.ec2.internal   Ready    <none>   57m   v1.34.1-eks-113cf36
```

NAME:
The name of the node, which uniquely identifies it within the cluster.
In this case, the node's name is ip-10-0-24-70.ec2.internal. This suggests the node is an EC2 instance in AWS, as indicated by the private IP address (10.0.24.70) and the .ec2.internal domain.
STATUS:
Indicates the current status of the node.
Ready means the node is healthy and available to run workloads (pods).
ROLES:
Specifies the role(s) assigned to the node.
<none> indicates that no specific roles (e.g., control-plane, worker) have been explicitly assigned to this node. However, in most cases, nodes without a role are worker nodes.
AGE:
Shows how long the node has been part of the cluster.
Here, the node has been active for 57 minutes.
VERSION:
Displays the version of Kubernetes running on the node.
In this case, the node is running Kubernetes version v1.34.1-eks-113cf36.
v1.34.1 refers to the Kubernetes version.
eks indicates that this is an Amazon Elastic Kubernetes Service (EKS) cluster.
113cf36 is a build identifier specific to the EKS release.
Key Points to Note
Node Health:
The STATUS column shows whether the node is Ready or experiencing issues (e.g., NotReady, Unknown).
A Ready status ensures that the node can schedule and run pods.
Node Roles:
Nodes can have roles such as control-plane (for managing the cluster) or worker (for running application workloads).
If no roles are specified (<none>), the node is typically a worker node.
Kubernetes Version:
The VERSION column helps verify that all nodes in the cluster are running compatible Kubernetes versions.
Mismatched versions between nodes can lead to compatibility issues.
AWS Integration:
The node name (ip-10-0-24-70.ec2.internal) confirms that this is an AWS EC2 instance.
The .ec2.internal domain is used for EC2 instances in AWS regions that do not have a custom VPC DNS hostname configuration.
Cluster Management:
Use this command to monitor the health and configuration of your cluster's nodes.
For more detailed information about a specific node, you can use:

```bash
kubectl describe node <node-name>
```


```bash
kubectl get nodes

# output
NAME                         STATUS   ROLES    AGE   VERSION
ip-10-0-24-70.ec2.internal   Ready    <none>   57m   v1.34.1-eks-113cf36
```

```bash
$ kubectl auth can-i "*" "*"

# output
yes
```

### RBAC Yaml files:

#### Viewer-Cluster-Role-Binding:
```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: my-viewer-binding
rolesRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
subjects:
  - kind: Group
    name: my-viewer-group
    apiGroup: rbac.authorization.k8s.io
```

This YAML configuration defines a Kubernetes ClusterRoleBinding object, which is used to bind a ClusterRole (a set of permissions) to a subject (in this case, a group). Let me break it down step by step:

Explanation of the Fields
`apiVersion: rbac.authorization.k8s.io/v1`
Specifies the API version for the Kubernetes Role-Based Access Control (RBAC) resources.
`rbac.authorization.k8s.io/v1` is the stable version of the RBAC API.
kind: ClusterRoleBinding

Indicates that this object is a ClusterRoleBinding.
A ClusterRoleBinding grants permissions across the entire cluster (as opposed to a RoleBinding, which is namespace-scoped).
metadata
Contains metadata about the object.
`name: my-viewer-binding`: The name of this ClusterRoleBinding. It uniquely identifies the binding within the cluster.
roleRef
Specifies the role being referenced by this binding.
apiGroup: rbac.authorization.k8s.io: The API group for RBAC resources.
kind: ClusterRole: Indicates that the referenced role is a ClusterRole.
name: view: Refers to the built-in view ClusterRole. This role provides read-only access to most objects in the cluster (e.g., Pods, Services, ConfigMaps) but does not allow modifying them or viewing secrets.
subjects
Defines the entities (users, groups, or service accounts) that are granted the permissions defined by the ClusterRole.
In this case:
kind: Group: Indicates that the subject is a group.
name: my-viewer-group: The name of the group being granted permissions.
apiGroup: rbac.authorization.k8s.io: The API group for RBAC subjects.
What Does This Configuration Do?
This ClusterRoleBinding binds the built-in view ClusterRole to the group my-viewer-group.
Members of the my-viewer-group will have read-only access to most resources in the cluster. They can view resources like Pods, Deployments, and Services, but they cannot modify them or access sensitive information like Secrets.
Key Points About RBAC
ClusterRole vs. Role:
A ClusterRole applies to the entire cluster, while a Role is scoped to a specific namespace.
ClusterRoleBinding vs. RoleBinding:
A ClusterRoleBinding applies the permissions cluster-wide, whereas a RoleBinding applies them only within a specific namespace.
Built-in Roles:
Kubernetes provides several built-in roles like view, edit, and admin for common use cases. These roles are predefined and can be reused without creating new ones.
Subjects:
Subjects can be of three types:
User: Represents an individual user (e.g., authenticated via an identity provider).
Group: Represents a collection of users.
ServiceAccount: Represents an identity used by pods or services running in the cluster.
Use Case
This configuration is useful when you want to grant a group of users (e.g., developers or auditors) read-only access to the cluster. For example:

Developers can monitor the status of their applications without being able to modify them.
Auditors can inspect cluster resources for compliance purposes.
How to Apply This Configuration
Save the YAML to a file, e.g., my-viewer-binding.yaml.

Apply the configuration using kubectl:
```bash
kubectl apply -f my-viewer-binding.yaml
```

Verify that the binding was created:
```bash
kubectl get clusterrolebinding my-viewer-binding
```
Additional Notes
If you need to grant permissions to a specific user instead of a group, you can replace the subjects section with:
```yaml
subjects:
  - kind: User
    name: alice
    apiGroup: rbac.authorization.k8s.io
```
To check the permissions granted by the view role, you can describe it:

```bash
kubectl describe clusterrole view
```

This configuration is a simple yet powerful way to manage access control in Kubernetes clusters using RBAC.

Create add developer-user.tf file:
```yaml
resource "aws_iam_user" "developer" {
  name = "developer"
}

resource "aws_iam_policy" "developer_eks" {
  name = "AmazonEKSDeveloperPolicy"

  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  POLICY
}

resource "aws_iam_user_policy_attachment" "developer_eks" {
  user = aws_iam_user.developer.name
  policy_arn = aws_iam_policy.developer_eks.arn
}

resource "aws_eks_access_entry" "developer" {
  cluster_name = aws_eks_cluster.eks.name
  principal_arn = aws_iam_user.developer.arn
  kubernetes_groups = ["my-viewer"]
}
```

#### Admin-Cluster-Role-Binding
```yaml
---
apiVersion: rbac.authorzation.k8s.io/v1
kind: ClusterRoleBinding
metedata:
  name: my-admin-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: my-admin
```
Run Code:
```bash
aws eks update-kubeconfig \
--region us-east-2 \
--name staging-demo
```

#### 10 Add Manager Role
This Terraform configuration sets up an AWS IAM role, policies, 
and user to manage access to an Amazon EKS (Elastic Kubernetes Service) cluster. 
It also configures an aws_eks_access_entry resource to grant Kubernetes-level 
permissions to the IAM role. Below is a detailed explanation of each part of the code with inline comments:

. Retrieve Current AWS Account Information
```bash
data "aws_caller_identity" "current" {}
```

Purpose: Retrieves information about the current AWS account and user.
Usage: This data source is used to dynamically fetch the AWS account ID (account_id) for constructing ARNs or other identifiers.
Key Attribute: data.aws_caller_identity.current.account_id provides the AWS account ID.

Create an IAM Role for Admin Access to EKS:
```hcl
resource "aws_iam_role" "eks_admin" {
  name = "${local.env}-${local.eks.name}"  # Dynamic name based on environment and EKS cluster name
  assume_role_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  POLICY
}
```

Purpose: Creates an IAM role named <env>-<eks_name> that can be assumed by the root account.
Details: The assume_role_policy allows the AWS account root user (or any IAM user/role in the account) to assume this role using the sts:AssumeRole action.
The Principal specifies who can assume the role. Here, it's set to the root account (arn:aws:iam::<account_id>:root).

Define an IAM Policy for Full EKS Admin Access:
```hcl
resource "aws_iam_policy" "eks_admin" {
  name = "AmazonEKSAdminPolicy"

  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "eks:*"
        ],
        "Effect": "Allow",
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "iam:PassRole"
        ],
        "Resource": "*",
        "Condition": {
          "StringEquals": {
            "iam:PassedToService": "eks.amazonaws.com"
          }
        }
      }
    ]
  }
  POLICY
}
```
Purpose: Defines an IAM policy (AmazonEKSAdminPolicy) that grants full administrative access to EKS resources.
Details: The first Statement allows all EKS-related actions (eks:*) on all resources (*).
The second Statement allows the iam:PassRole action but only when the role is passed to the EKS service (eks.amazonaws.com). This ensures that roles can only be used for EKS purposes.

Attach the Admin Policy to the IAM Role:
```hcl
resource "aws_iam_role_policy_attachment" "eks_admin" {
  role = aws_iam_role.eks_admin.name  # Reference the IAM role created earlier
  policy_arn = aws_iam_policy.eks_admin.arn  # Reference the IAM policy created earlier
}
```
> Purpose: Attaches the AmazonEKSAdminPolicy to the eks_admin IAM role.
> Details: The role attribute references the name of the IAM role (eks_admin).
The policy_arn attribute references the ARN of the IAM policy (AmazonEKSAdminPolicy).

Create an IAM User for Management:
```hcl
resource "aws_iam_user" "manager" {
  name = "manager"
}
```
> Purpose: Creates an IAM user named manager.
> Details: This user will later be granted permissions to assume the eks_admin role.

Define a Policy for Assuming the Admin Role:
```hcl
resource "aws_iam_policy" "eks_assume_admin" {
  name = "AmazonEKSAssumeAdminPolicy"
  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "sts:AssumeRole"
        ],
        "Effect": "Allow",
        "Resource": "${aws_iam_role.eks_admin.arn}"
      }
    ]
  }
  POLICY
}
```
> Purpose: Defines an IAM policy (AmazonEKSAssumeAdminPolicy) that allows the sts:AssumeRole action on the eks_admin IAM role.
> Details: The Resource specifies the ARN of the eks_admin role.
This policy enables the manager user to assume the eks_admin role and gain its permissions.

Attach the Assume Role Policy to the Manager User:
```hcl
resource "aws_iam_user_policy_attachment" "manager" {
  user = aws_iam_user.manager.name  # Reference the IAM user created earlier
  policy_arn = aws_iam_policy.eks_assume_admin.arn  # Reference the IAM policy created earlier
}
```
> Purpose: Attaches the AmazonEKSAssumeAdminPolicy to the manager IAM user.
> Details: The user attribute references the name of the IAM user (manager).
The policy_arn attribute references the ARN of the IAM policy (AmazonEKSAssumeAdminPolicy).

Grant Kubernetes-Level Access via EKS Access Entry:
```hcl
resource "aws_eks_access_entry" "manager" {
  cluster_name = aws_eks_cluster.eks.name  # Reference the EKS cluster created elsewhere
  principal_arn = aws_iam_role.eks_admin.arn  # Reference the IAM role created earlier
  kubernetes_groups = ["my-admin"]  # Assigns the user to the "my-admin" Kubernetes group
}
```
> Purpose: Configures an EKS access entry to grant Kubernetes-level permissions to the eks_admin IAM role.
> Details: The cluster_name specifies the EKS cluster to which the access entry applies.
The principal_arn specifies the IAM role (eks_admin) that will have access to the cluster.
The kubernetes_groups assigns the role to the my-admin Kubernetes group, which should have corresponding permissions defined in the Kubernetes RBAC system.

Summary of Workflow
IAM Role Creation:
An IAM role (eks_admin) is created with permissions to manage EKS resources.
The role can be assumed by the root account.
IAM Policy Creation:
A policy (AmazonEKSAdminPolicy) is created to grant full EKS admin access.
Another policy (AmazonEKSAssumeAdminPolicy) is created to allow assuming the eks_admin role.
IAM User Setup:
An IAM user (manager) is created and granted permissions to assume the eks_admin role.
Kubernetes Access:
An EKS access entry is created to map the eks_admin role to the my-admin Kubernetes group, enabling Kubernetes-level permissions.
Key Points
Separation of Concerns:
The eks_admin role is designed for EKS management, while the manager user is granted limited permissions to assume the role.
Dynamic Configuration:
The use of variables (local.env, local.eks.name) ensures flexibility and reusability of the Terraform code.
Security:
The sts:AssumeRole action is tightly controlled, ensuring only authorized users/roles can assume the eks_admin role

Then Run:
```bash
aws configure --profile manager
```
and Add the Access_Key_Id and Secret_Access_Key

Then:
```bash
aws sts assume-role \
--role-arn:aws:aws:iam::<Account-Id>:role/staging-demo-eks-admin \
--role-session-name manager-session \
--profile manager
```
Then:
```bash
vi ~/.aws/config
```
add:
```zsh
[default]
[profile developer]
[profile eks-admin]
role_arn = arn:aws:iam::<account-id>:role/staging-demo-eks-admin
source_profile = manager
```
Then:
```bash 
aws eks update-kubeconfig \
--region us-east-2 \
--name staging-demon \
--profile eks-admin
```
Then: 
```bash
kubectl config view --minify
```
Get the Pods:
```bash
kubectl get pods
```
and:
```bash
kubectl auth can -i 
```
### Helm Provider
The comments are added inline to clarify the purpose and functionality of each resource
```hcl
# Retrieve information about the current AWS account and user.
# This data source provides details such as the account ID, which is used in constructing ARNs.
data "aws_caller_identity" "current" {}

# Create an IAM role for administering EKS resources.
# This role will be assumed by authorized users or services to manage the EKS cluster.
resource "aws_iam_role" "eks_admin" {
  name = "${local.env}-${local.eks.name}"  # Dynamically generate the role name using environment and EKS cluster name variables.

  # Define the trust policy for the role, specifying who can assume it.
  assume_role_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",  # Allow the specified principal to assume this role.
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"  # Allow the root account to assume this role.
        },
        "Action": "sts:AssumeRole"  # The action required to assume the role.
      }
    ]
  }
  POLICY
}

# Define an IAM policy granting full administrative access to EKS resources.
# This policy allows all EKS-related actions and limited IAM actions for EKS purposes.
resource "aws_iam_policy" "eks_admin" {
  name = "AmazonEKSAdminPolicy"  # Name of the policy.

  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "eks:*"  # Allow all actions related to EKS (e.g., creating, updating, deleting clusters).
        ],
        "Effect": "Allow",  # Grant permission to perform the specified actions.
        "Resource": "*"  # Apply the policy to all resources.
      },
      {
        "Effect": "Allow",  # Grant permission to pass roles to EKS services.
        "Action": [
          "iam:PassRole"  # Allow passing roles to other services.
        ],
        "Resource": "*",  # Apply the policy to all resources.
        "Condition": {
          "StringEquals": {
            "iam:PassedToService": "eks.amazonaws.com"  # Restrict role passing to the EKS service only.
          }
        }
      }
    ]
  }
  POLICY
}

# Attach the AmazonEKSAdminPolicy to the eks_admin IAM role.
# This grants the role the permissions defined in the policy.
resource "aws_iam_role_policy_attachment" "eks_admin" {
  role       = aws_iam_role.eks_admin.name  # Reference the eks_admin role created earlier.
  policy_arn = aws_iam_policy.eks_admin.arn  # Reference the ARN of the AmazonEKSAdminPolicy.
}

# Create an IAM user named "manager".
# This user will be granted permissions to assume the eks_admin role.
resource "aws_iam_user" "manager" {
  name = "manager"  # Name of the IAM user.
}

# Define a policy allowing the manager user to assume the eks_admin role.
# This policy grants the sts:AssumeRole action on the eks_admin role.
resource "aws_iam_policy" "eks_assume_admin" {
  name = "AmazonEKSAssumeAdminPolicy"  # Name of the policy.

  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "sts:AssumeRole"  # Allow assuming the eks_admin role.
        ],
        "Effect": "Allow",  # Grant permission to perform the specified action.
        "Resource": "${aws_iam_role.eks_admin.arn}"  # Specify the ARN of the eks_admin role.
      }
    ]
  }
  POLICY
}

# Attach the AmazonEKSAssumeAdminPolicy to the manager IAM user.
# This grants the user the ability to assume the eks_admin role.
resource "aws_iam_user_policy_attachment" "manager" {
  user       = aws_iam_user.manager.name  # Reference the manager user created earlier.
  policy_arn = aws_iam_policy.eks_assume_admin.arn  # Reference the ARN of the AmazonEKSAssumeAdminPolicy.
}

# Create an EKS access entry to map the eks_admin role to a Kubernetes group.
# This enables Kubernetes-level permissions for the eks_admin role.
resource "aws_eks_access_entry" "manager" {
  cluster_name = aws_eks_cluster.eks.name  # Reference the EKS cluster created elsewhere.
  principal_arn = aws_iam_role.eks_admin.arn  # Reference the ARN of the eks_admin role.
  kubernetes_groups = ["my-admin"]  # Assign the role to the "my-admin" Kubernetes group.
}
```

### Meterics Server
Kubernetes Metrics Server
Metrics Server is a scalable, efficient source of container resource metrics for Kubernetes built-in autoscaling pipelines.

Metrics Server collects resource metrics from Kubelets and exposes them in Kubernetes apiserver through Metrics API for use by Horizontal Pod Autoscaler and Vertical Pod Autoscaler. Metrics API can also be accessed by kubectl top, making it easier to debug autoscaling pipelines.

Metrics Server is not meant for non-autoscaling purposes. For example, don’t use it to forward metrics to monitoring solutions, or as a source of monitoring solution metrics. In such cases please collect metrics from Kubelet /metrics/resource endpoint directly.

Metrics Server offers:

A single deployment that works on most clusters (see Requirements)
Fast autoscaling, collecting metrics every 15 seconds.
Resource efficiency, using 1 mili core of CPU and 2 MB of memory for each node in a cluster.
Scalable support up to 5,000 node clusters.
Use cases
You can use Metrics Server for:

CPU/Memory based horizontal autoscaling (learn more about Horizontal Autoscaling)
Automatically adjusting/suggesting resources needed by containers (learn more about Vertical Autoscaling)
Don’t use Metrics Server when you need:

Non-Kubernetes clusters
An accurate source of resource usage metrics
Horizontal autoscaling based on other resources than CPU/Memory
For unsupported use cases, check out full monitoring solutions like Prometheus.

Requirements
Metrics Server has specific requirements for cluster and network configuration. These requirements aren’t the default for all cluster distributions. Please ensure that your cluster distribution supports these requirements before using Metrics Server:

Metrics Server must be reachable from kube-apiserver by container IP address (or node IP if hostNetwork is enabled).
The kube-apiserver must enable an aggregation layer.
Nodes must have Webhook authentication and authorization enabled.
Kubelet certificate needs to be signed by cluster Certificate Authority (or disable certificate validation by passing --kubelet-insecure-tls to Metrics Server)
Container runtime must implement a container metrics RPCs (or have cAdvisor support)

```yaml
# meterics-server.tf
resource "helm_release" "meterics_server" {
  name = "meterics-server"

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart = "meterics-server"
  namespace = "kube-system"
  version = "3.12.1"

  values = [file("${path.module}/values/meterics-server.yaml")]

  depends_on = [ aws_eks_node_group.general ]
}
```

Create values/meterics-server.tf
```hcl
---
defaultArgs:
  - --cert-dir=/tmp
  - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
  - --kubelet-use-node-status-port
  - --metric-resolution=15s
  - --secure-port=10250
```
Then run: 
```bash
cd terraform
# then
terraform init
# then 
terraform apply
```
Check the Pods
```bash
kubectl get pods -n kube-system
```

Check Logs:
```bash
kubectl logs -l app.kubernetes.io/instance=meterics-server -f -n kube-system
```

Test the Meterics Server
```bash
kubectl top pods -n kube-system
```
