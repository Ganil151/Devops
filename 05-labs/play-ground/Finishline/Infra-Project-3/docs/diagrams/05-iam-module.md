# IAM Module Diagram

## Module: terraform/modules/iam

```mermaid
flowchart TB
    subgraph IAM_Module["IAM Module"]

        subgraph JumphostRole["Jumphost IAM Role"]
            Role["aws_iam_role<br/>jumphost_role"]

            Policy1["aws_iam_role_policy_attachment<br/>AmazonEKSClusterPolicy"]
            Policy2["aws_iam_role_policy<br/>jumphost_eks_readonly"]

            ReadOnlyPolicy["Custom Policy<br/>eks:DescribeCluster<br/>eks:DescribeNodegroup<br/>eks:ListNodegroups<br/>eks:AccessKubernetesApi"]
        end

        subgraph EKSAccess["EKS Access Configuration"]
            AccessEntry["aws_eks_access_entry<br/>jumphost_access"]
            PolicyAssociation["aws_eks_access_policy_association<br/>jumphost_admin"]

            AdminPolicy["AmazonEKSClusterAdminPolicy<br/>cluster scope"]
        end

        subgraph Inputs["Input Variables"]
            project_name["var.project_name"]
            environment["var.environment"]
            cluster_name["var.cluster_name"]
        end

        subgraph Outputs["Output Values"]
            jumphost_role_name["jumphost_role_name"]
            jumphost_role_arn["jumphost_role_arn"]
        end
    end

    EKS["EKS Cluster"]
    EC2["EC2 Instance<br/>Jumphost"]

    Role --> Policy1
    Role --> Policy2
    Policy2 --> ReadOnlyPolicy

    Role -->|principal_arn| AccessEntry
    EKS -->|cluster_name| AccessEntry
    AccessEntry --> PolicyAssociation
    PolicyAssociation --> AdminPolicy

    Role -->|IAM Role| EC2
    EC2 -->|Assume Role| EKS
```

---

## IAM Role & Policy Architecture

```mermaid
flowchart TB
    subgraph AWS_IAM["AWS IAM"]

        subgraph JumphostRole["Jumphost Role"]
            RoleIcon["📛 jumphost-role"]

            subgraph Policies["Attached Policies"]
                ManagedPolicy["📄 AmazonEKSClusterPolicy<br/>(AWS Managed)"]
                CustomPolicy["📄 eks-readonly-policy<br/>(Custom)"]
            end

            subgraph TrustPolicy["Trust Policy"]
                Trust["Service: ec2.amazonaws.com<br/>Action: sts:AssumeRole"]
            end
        end

        subgraph EKS_Access["EKS Access Management"]
            AccessEntry["🔑 EKS Access Entry<br/>Type: STANDARD"]
            PolicyAssoc["📋 Policy Association<br/>AmazonEKSClusterAdminPolicy"]
        end

    end

    Jumphost["🐧 Jumphost EC2<br/>AL2023"]
    EKS_Cluster["☸️ EKS Cluster"]
    kubectl["🔧 kubectl/CLI"]

    Trust -->|Assume| RoleIcon
    RoleIcon --> ManagedPolicy
    RoleIcon --> CustomPolicy

    RoleIcon -->|principal_arn| AccessEntry
    AccessEntry --> PolicyAssoc

    PolicyAssoc -->|Access| EKS_Cluster

    Jumphost -->|Uses Role| RoleIcon
    Jumphost -->|eks:DescribeCluster| EKS_Cluster
    Jumphost -->|Admin Access| EKS_Cluster
    kubectl -->|kubectl commands| EKS_Cluster
```

---

## EKS Access Entry Flow

```mermaid
sequenceDiagram
    participant EC2 as Jumphost EC2
    participant IAM as AWS IAM
    participant STS as AWS STS
    participant EKS as EKS Cluster

    EC2->>IAM: Assume jumphost-role
    IAM->>STS: Request temporary credentials
    STS->>EC2: Return temporary credentials

    Note over EC2,EKS: Using temporary credentials

    EC2->>EKS: DescribeCluster
    EKS->>EC2: Cluster details

    EC2->>EKS: Access via kubectl
    Note over EKS: Verify access via<br/>AccessEntry + PolicyAssociation
    EKS->>EC2: Allow access (Admin)
```

---

## Key Features

| Feature              | Implementation                              | Reference |
| -------------------- | ------------------------------------------- | --------- |
| **Jumphost Role**    | EC2 instance role for bastion access        | §83       |
| **EKS Policy**       | AmazonEKSClusterPolicy attached             | §84       |
| **Read-only Policy** | Custom policy for describe actions          | §84       |
| **EKS Access Entry** | STANDARD type access entry                  | §87       |
| **Admin Policy**     | AmazonEKSClusterAdminPolicy (cluster scope) | §89       |
| **Least Privilege**  | Describe access + admin via EKS IAM         | §84, §89  |

---

## Policy Details

```mermaid
flowchart TB
    subgraph Policies["IAM Policies"]

        subgraph Managed["AWS Managed Policy"]
            AmazonEKSCluster["AmazonEKSClusterPolicy<br/>Allows EKS cluster operations"]
        end

        subgraph Custom["Custom Inline Policy"]
            ReadOnlyActions["jumphost-eks-readonly"]

            subgraph Actions["Allowed Actions"]
                Action1["eks:DescribeCluster"]
                Action2["eks:DescribeNodegroup"]
                Action3["eks:ListNodegroups"]
                Action4["eks:AccessKubernetesApi"]
            end
        end

        subgraph EKS_Managed["EKS Access Policy"]
            AdminPolicy["AmazonEKSClusterAdminPolicy<br/>Full cluster admin access<br/>Scope: cluster"]
        end
    end

    Policies --> Role
    Role --> EC2

    EKS --> AccessEntry
    AccessEntry --> PolicyAssoc
    PolicyAssoc --> AdminPolicy
```

---

## Outputs Reference

```mermaid
classDiagram
    class Outputs {
        <<output>>
        +string jumphost_role_name
        +string jumphost_role_arn
    }

    class IAMRole {
        <<resource>>
        +string id
        +string name
        +string arn
        +string path
    }

    class EKSAccessEntry {
        <<resource>>
        +string id
        +string cluster_name
        +string principal_arn
        +string type
    }

    Outputs --> IAMRole
    Outputs --> EKSAccessEntry
```

---

_Generated from: terraform/modules/iam/main.tf_
