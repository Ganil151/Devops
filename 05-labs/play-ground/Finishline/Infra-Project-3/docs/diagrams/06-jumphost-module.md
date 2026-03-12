# JumpHost Module Diagram

## Module: terraform/modules/jumphost

```mermaid
flowchart TB
    subgraph JumpHost_Module["JumpHost Module"]

        subgraph SecurityGroup["Security Group"]
            SG["aws_security_group<br/>jumphost_sg"]

            subgraph IngressRules["Ingress Rules (Dynamic)"]
                SSH1["ingress<br/>SSH (22)<br/>var.home_ip_cidrs[0]"]
                SSH2["ingress<br/>SSH (22)<br/>var.home_ip_cidrs[1]"]
                SSH3["ingress<br/>SSH (22)<br/>var.home_ip_cidrs[n]"]
            end

            EgressRule["egress<br/>All Traffic<br/>0.0.0.0/0"]
        end

        subgraph EC2Instance["EC2 Instance"]
            Instance["aws_instance<br/>jumphost"]

            AMI["data.aws_ami<br/>al2023<br/>Amazon Linux 2023"]

            UserData["user_data<br/>Tool installation<br/>kubectl, helm, awscli"]

            RootBlock["root_block_device<br/>volume_size: 20GB<br/>volume_type: gp3<br/>encrypted: true"]
        end

        subgraph InstanceProfile["IAM Instance Profile"]
            Profile["aws_iam_instance_profile<br/>jumphost_profile"]
            Role["var.jumphost_role_name<br/>(from IAM module)"]
        end

        subgraph ElasticIP["Elastic IP"]
            EIP["aws_eip<br/>jumphost_eip"]
        end

        subgraph Inputs["Input Variables"]
            vpc_id["var.vpc_id"]
            subnet_id["var.subnet_id"]
            home_ip_cidrs["var.home_ip_cidrs"]
            instance_type["var.instance_type<br/>default: t3.small"]
            key_pair_name["var.key_pair_name"]
            jumphost_role_name["var.jumphost_role_name"]
        end

        subgraph Outputs["Output Values"]
            instance_id["instance_id"]
            public_ip["public_ip"]
            private_ip["private_ip"]
            security_group_id["security_group_id"]
        end
    end

    Developer["Developer<br/>Admin"]
    Internet["Internet"]
    EKS["EKS Cluster"]

    SG --> SSH1
    SG --> SSH2
    SG --> SSH3
    SG --> EgressRule

    Instance --> AMI
    Instance --> UserData
    Instance --> RootBlock
    Instance --> SG
    Instance --> Profile
    Instance --> EIP
    Instance --> key_pair_name

    Profile --> Role

    Developer -->|SSH (restricted)| Instance
    Instance -->|EKS Access| EKS
    EIP --> Internet
```

---

## JumpHost Architecture

```mermaid
flowchart TB
    subgraph AWS["AWS Cloud"]

        subgraph VPC["VPC"]

            subgraph PublicSubnet["Public Subnet (AZ 1)"]
                JumpHost["🖥️ JumpHost<br/>AL2023<br/>t3.small"]

                subgraph Tools["Installed Tools"]
                    kubectl["kubectl"]
                    helm["helm"]
                    awscli["aws-cli"]
                    terraform["terraform"]
                end
            end

            SG["🔒 Security Group<br/>SSH: Home IPs only<br/>Outbound: All"]
            EIP["🔗 Elastic IP"]
        end

        subgraph IAM_Role["IAM Role"]
            RoleName["📛 jumphost-role"]
            Policy1["AmazonEKSClusterPolicy"]
            Policy2["eks-readonly-policy"]
        end

    end

    Admin["👤 Admin<br/>Developer"]
    Internet["🌐 Internet"]
    EKS["☸️ EKS Cluster"]

    Admin -->|SSH :22<br/>Home IP Only| JumpHost
    JumpHost -->|Assume Role| RoleName
    RoleName --> Policy1
    RoleName --> Policy2

    JumpHost -->|eks:DescribeCluster| EKS
    JumpHost -->|kubectl access| EKS
    JumpHost --> Internet
    JumpHost --> EIP
```

---

## Security Group Rules

```mermaid
flowchart TB
    subgraph Inbound["Inbound Rules (Ingress)"]
        SSH_Home1["SSH<br/>22<br/>Home IP CIDR 1"]
        SSH_Home2["SSH<br/>22<br/>Home IP CIDR 2"]
        SSH_Home3["SSH<br/>22<br/>Home IP CIDR n"]
    end

    subgraph Outbound["Outbound Rules (Egress)"]
        All_Traffic["All Traffic<br/>0.0.0.0/0"]
    end

    subgraph Action["Action"]
        Allow["✅ ALLOW"]
        Deny["❌ DENY other traffic"]
    end

    subgraph SG["Security Group: jumphost-sg"]
        Rules["Rules"]
    end

    SSH_Home1 --> Allow
    SSH_Home2 --> Allow
    SSH_Home3 --> Allow
    All_Traffic --> Allow

    Allow --> Rules
    Deny --> Rules
```

---

## Key Features

| Feature               | Implementation                      | Reference |
| --------------------- | ----------------------------------- | --------- |
| **AMI**               | Amazon Linux 2023 (AL2023)          | §69       |
| **SSH Restriction**   | Only from `var.home_ip_cidrs`       | §70       |
| **Tool Installation** | kubectl, helm, awscli, terraform    | §73       |
| **IAM Profile**       | Instance profile with jumphost role | §83       |
| **Key Pair**          | SSH key for authentication          | §71       |
| **EIP**               | Static public IP address            | §69       |
| **Security**          | SSH restricted to home IP ranges    | §70       |

---

## SSH Access Flow

```mermaid
sequenceDiagram
    participant Admin as Admin/Developer
    participant SG as Security Group
    participant EC2 as JumpHost EC2
    participant IAM as IAM Role
    participant EKS as EKS Cluster

    Admin->>SG: SSH Connection Attempt (port 22)

    alt Source IP Allowed?
        SG->>SG: Check home_ip_cidrs
        SG->>EC2: ✅ ALLOW
        EC2->>IAM: Assume jumphost-role
        IAM->>EC2: Return credentials

        EC2->>EKS: eks:DescribeCluster
        EKS->>EC2: Cluster info

        EC2->>Admin: ✅ SSH Session Established

        Note over EC2,Admin: Admin can now run<br/>kubectl commands
    else Source IP Not Allowed
        SG->>Admin: ❌ DENY
    end
```

---

## User Data Script

```mermaid
flowchart TB
    subgraph UserData["user_data.sh"]

        Update["🔄 yum update -y"]
        Tools["📦 Install Tools"]

        subgraph Installation["Package Installation"]
            AWSCLI["aws-cli"]
            Kubectl["kubectl"]
            Helm["helm"]
            Docker["docker"]
            Terrform["terraform"]
        end

        Configure["⚙️ Configure"]

        subgraph Config["Configuration"]
            KubeConfig["Setup kubeconfig"]
            DockerStart["Start docker service"]
            Alias["Create aliases"]
        end
    end

    EC2["EC2 Instance Launch"]

    EC2 --> UserData
    UserData --> Update
    Update --> Tools
    Tools --> AWSCLI
    Tools --> Kubectl
    Tools --> Helm
    Tools --> Docker
    Tools --> Terrform
    Tools --> Configure
    Configure --> KubeConfig
    Configure --> DockerStart
    Configure --> Alias
```

---

## Outputs Reference

```mermaid
classDiagram
    class Outputs {
        <<output>>
        +string instance_id
        +string public_ip
        +string private_ip
        +string security_group_id
    }

    class EC2Instance {
        <<resource>>
        +string id
        +string ami
        +string instance_type
        +string public_ip
        +string private_ip
    }

    class ElasticIP {
        <<resource>>
        +string id
        +string public_ip
        +string instance_id
    }

    Outputs --> EC2Instance
    Outputs --> ElasticIP
```

---

_Generated from: terraform/modules/jumphost/main.tf_
