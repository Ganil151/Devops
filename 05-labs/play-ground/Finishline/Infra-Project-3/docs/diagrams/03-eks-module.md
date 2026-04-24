# EKS Module Diagram

## Module: terraform/modules/eks

```mermaid
flowchart TB
    subgraph EKS_Module["EKS Module"]

        subgraph IAM_Roles["IAM Roles"]
            ClusterRole["aws_iam_role<br/>eks_cluster_role"]
            NodeGroupRole["aws_iam_role<br/>eks_node_group_role"]

            ClusterPolicy1["aws_iam_role_policy_attachment<br/>AmazonEKSClusterPolicy"]
            ClusterPolicy2["aws_iam_role_policy_attachment<br/>AmazonEKSVPCResourceController"]

            NodePolicy1["aws_iam_role_policy_attachment<br/>AmazonEKSWorkerNodePolicy"]
            NodePolicy2["aws_iam_role_policy_attachment<br/>AmazonEKS_CNI_Policy"]
            NodePolicy3["aws_iam_role_policy_attachment<br/>AmazonEC2ContainerRegistryReadOnly"]
        end

        subgraph EKS_Cluster["EKS Cluster"]
            Cluster["aws_eks_cluster<br/>finishline_eks"]

            subgraph NodeGroup["Managed Node Group"]
                NodeGrp["aws_eks_node_group<br/>finishline_node_group"]
            end
        end

        subgraph OIDC["OIDC Provider"]
            TLSCert["data.tls_certificate<br/>eks"]
            OIDCProvider["aws_iam_openid_connect_provider<br/>eks"]
        end

        subgraph Inputs["Input Variables"]
            cluster_name["var.cluster_name"]
            cluster_version["var.cluster_version<br/>default: 1.30"]
            subnet_ids["var.subnet_ids"]
            instance_types["var.instance_types<br/>[t3.medium]"]
            endpoint_private["var.endpoint_private_access"]
            endpoint_public["var.endpoint_public_access"]
            log_types["var.cluster_enabled_log_types"]
        end

        subgraph Outputs["Output Values"]
            cluster_name_out["cluster_name"]
            cluster_arn["cluster_arn"]
            cluster_endpoint["cluster_endpoint"]
            node_group_role_arn["node_group_role_arn"]
            oidc_provider_arn["oidc_provider_arn"]
        end
    end

    VPC["VPC Subnets"]

    ClusterRole --> ClusterPolicy1
    ClusterRole --> ClusterPolicy2
    Cluster --> ClusterRole

    NodeGroupRole --> NodePolicy1
    NodeGroupRole --> NodePolicy2
    NodeGroupRole --> NodePolicy3
    NodeGrp --> NodeGroupRole

    Cluster --> NodeGrp

    VPC -->|subnet_ids| Cluster
    Cluster -->|subnet_ids| NodeGrp

    Cluster -->|issuer URL| TLSCert
    TLSCert --> OIDCProvider
```

---

## EKS Cluster Architecture

```mermaid
flowchart TB
    subgraph AWS["AWS Cloud"]

        subgraph VPC["VPC (Private Subnets)"]
            Subnet1["Private Subnet 1<br/>AZ 1"]
            Subnet2["Private Subnet 2<br/>AZ 2"]
            Subnet3["Private Subnet 3<br/>AZ 3"]
        end

        subgraph EKS["EKS Cluster"]
            ControlPlane["🎛️<br/>EKS Control Plane<br/>Managed by AWS"]

            subgraph NodeGroup["Managed Node Group"]
                Node1["🖥️ Node 1<br/>t3.medium<br/>Bottlerocket x86_64"]
                Node2["🖥️ Node 2<br/>t3.medium<br/>Bottlerocket x86_64"]
            end
        end

        subgraph IAM["IAM"]
            ClusterRole["📛 Cluster Role<br/>AmazonEKSClusterPolicy<br/>AmazonEKSVPCResourceController"]
            NodeRole["📛 Node Role<br/>AmazonEKSWorkerNodePolicy<br/>AmazonEKS_CNI_Policy<br/>ECR ReadOnly"]
            OIDC["🔐 OIDC Provider<br/>For Service Accounts"]
        end

        Users["👤 Users/<br/>Applications"]
        External["🌐 External<br/>Services"]
    end

    Subnet1 --> ControlPlane
    Subnet2 --> ControlPlane
    Subnet3 --> ControlPlane

    ControlPlane --> Node1
    ControlPlane --> Node2

    IAM -->|Assume Role| ControlPlane
    IAM -->|Assume Role| Node1
    IAM -->|Assume Role| Node2

    ClusterRole --> ControlPlane
    NodeRole --> Node1
    NodeRole --> Node2

    OIDC -->|Authenticate| ControlPlane

    Users -->|kubectl| ControlPlane
    External -->|API Calls| ControlPlane
```

---

## Node Group Configuration

```mermaid
flowchart LR
    subgraph NodeGroupConfig["Node Group Configuration"]
        AMI["AMI Type<br/>BOTTLEROCKET_x86_64"]
        Instance["Instance Type<br/>t3.medium"]
        Capacity["Capacity Type<br/>ON_DEMAND"]
        Scaling["Scaling Config<br/>desired: 2<br/>min: 2<br/>max: 2"]
        Disk["Disk Size<br/>20 GB"]
        Repair["Node Repair<br/>enabled: true"]
    end

    NodeGroupConfig --> NodeGroup
    NodeGroup["aws_eks_node_group<br/>finishline_node_group"]
```

---

## Key Features

| Feature             | Implementation                  | Reference |
| ------------------- | ------------------------------- | --------- |
| **Cluster Version** | Kubernetes 1.30 (configurable)  | §74       |
| **Node Count**      | Exactly 2 nodes (fixed size)    | §79       |
| **Instance Type**   | t3.medium                       | §75       |
| **AMI Type**        | Bottlerocket x86_64             | §76       |
| **Capacity Type**   | On-Demand                       | §79       |
| **IAM Roles**       | Cluster role + Node group role  | §76       |
| **OIDC Provider**   | Enabled for service account IAM | §76       |

---

## Outputs Reference

```mermaid
classDiagram
    class Outputs {
        <<output>>
        +string cluster_name
        +string cluster_arn
        +string cluster_endpoint
        +string cluster_certificate_authority_data
        +string node_group_role_arn
        +string oidc_provider_arn
        +list node_group_ids
    }

    class EKSCluster {
        <<resource>>
        +string id
        +string name
        +string arn
        +string endpoint
    }

    class NodeGroup {
        <<resource>>
        +string id
        +string arn
        +list node_group_name
    }

    Outputs --> EKSCluster
    Outputs --> NodeGroup
```

---

_Generated from: terraform/modules/eks/main.tf_
