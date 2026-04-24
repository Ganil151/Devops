# VPC Module Diagram

## Module: terraform/modules/vpc

```mermaid
flowchart TB
    subgraph VPC_Module["VPC Module"]
        subgraph Resources["AWS Resources"]
            VPC["aws_vpc<br/>finishline_vpc<br/>CIDR: var.vpc_cidr"]

            IGW["aws_internet_gateway<br/>finishline_igw"]

            PublicSubnet1["aws_subnet<br/>finishline_public_subnet[0]<br/>Public Subnet 1"]
            PublicSubnet2["aws_subnet<br/>finishline_public_subnet[1]<br/>Public Subnet 2"]
            PublicSubnet3["aws_subnet<br/>finishline_public_subnet[2]<br/>Public Subnet 3"]

            PrivateSubnet1["aws_subnet<br/>finishline_private_subnet[0]<br/>Private Subnet 1"]
            PrivateSubnet2["aws_subnet<br/>finishline_private_subnet[1]<br/>Private Subnet 2"]
            PrivateSubnet3["aws_subnet<br/>finishline_private_subnet[2]<br/>Private Subnet 3"]

            PublicRT["aws_route_table<br/>public"]
            PrivateRT["aws_route_table<br/>private"]

            PublicRoute["aws_route<br/>public_internet_gateway<br/>0.0.0.0/0 → IGW"]
            PrivateRoute["aws_route<br/>private_nat_gateway<br/>0.0.0.0/0 → NAT"]

            EIP["aws_eip<br/>nat_gateway_eip"]
            NAT["aws_nat_gateway<br/>main"]

            subgraph Associations["Route Table Associations"]
                PublicAssoc1["aws_route_table_association<br/>public[0]"]
                PublicAssoc2["aws_route_table_association<br/>public[1]"]
                PublicAssoc3["aws_route_table_association<br/>public[2]"]
                PrivateAssoc1["aws_route_table_association<br/>private[0]"]
                PrivateAssoc2["aws_route_table_association<br/>private[1]"]
                PrivateAssoc3["aws_route_table_association<br/>private[2]"]
            end
        end

        subgraph Inputs["Input Variables"]
            vpc_cidr["var.vpc_cidr<br/>default: 10.0.0.0/16"]
            azs["var.availability_zones<br/>[az1, az2, az3]"]
            public_cidrs["var.public_subnets_cidrs"]
            private_cidrs["var.private_subnets_cidrs"]
            dns_hostnames["var.enable_dns_hostnames"]
            dns_support["var.enable_dns_support"]
        end

        subgraph Outputs["Output Values"]
            vpc_id["main_vpc_id"]
            public_subnet_ids["main_public_subnet_ids"]
            private_subnet_ids["main_private_subnet_ids"]
            igw_id["main_igw_id"]
            nat_gateway_id["main_nat_gateway_id"]
            public_rt_id["main_public_route_table_id"]
            private_rt_id["main_private_route_table_id"]
        end
    end

    Internet["Internet"]

    VPC --> IGW
    VPC --> PublicSubnet1
    VPC --> PublicSubnet2
    VPC --> PublicSubnet3
    VPC --> PrivateSubnet1
    VPC --> PrivateSubnet2
    VPC --> PrivateSubnet3

    IGW --> PublicRoute
    PublicRoute --> PublicRT

    PublicRT --> PublicAssoc1
    PublicRT --> PublicAssoc2
    PublicRT --> PublicAssoc3

    PublicAssoc1 --> PublicSubnet1
    PublicAssoc2 --> PublicSubnet2
    PublicAssoc3 --> PublicSubnet3

    EIP --> NAT
    PublicSubnet1 --> NAT
    NAT --> PrivateRoute
    PrivateRoute --> PrivateRT

    PrivateRT --> PrivateAssoc1
    PrivateRT --> PrivateAssoc2
    PrivateRT --> PrivateAssoc3

    PrivateAssoc1 --> PrivateSubnet1
    PrivateAssoc2 --> PrivateSubnet2
    PrivateAssoc3 --> PrivateSubnet3

    IGW --> Internet
    NAT --> Internet

    PublicSubnet1 -.->|subnet_ids| ALB
    PublicSubnet1 -.->|subnet_id| Jumphost
    PrivateSubnet1 -.->|subnet_ids| EKS
```

---

## VPC Architecture Diagram

```mermaid
flowchart TB
    subgraph AWS_VPC["VPC: 10.0.0.0/16"]

        subgraph PublicSubnets["Public Subnets (3 AZs)"]
            PS1["AZ 1: 10.0.1.0/24"]
            PS2["AZ 2: 10.0.2.0/24"]
            PS3["AZ 3: 10.0.3.0/24"]
        end

        subgraph PrivateSubnets["Private Subnets (3 AZs)"]
            PVS1["AZ 1: 10.0.101.0/24"]
            PVS2["AZ 2: 10.0.102.0/24"]
            PVS3["AZ 3: 10.0.103.0/24"]
        end

        IGW["🌐<br/>Internet<br/>Gateway"]

        subgraph NAT_Zone["NAT Gateway (AZ 1)"]
            NAT_GW["NAT Gateway"]
            NAT_EIP["Elastic IP"]
        end

        subgraph RouteTables["Route Tables"]
            PubRT["Public RT<br/>0.0.0.0/0 → IGW"]
            PrivRT["Private RT<br/>0.0.0.0/0 → NAT"]
        end

    end

    Internet["🌍 Internet"]
    ALB_Ext["🔵 ALB Traffic"]
    EKS_Int["🟢 EKS Traffic"]

    Internet --> IGW
    IGW --> PubRT
    PubRT --> PS1
    PubRT --> PS2
    PubRT --> PS3

    PS1 --> NAT_GW
    NAT_GW --> NAT_EIP
    NAT_GW --> PrivRT
    PrivRT --> PVS1
    PrivRT --> PVS2
    PrivRT --> PVS3

    NAT_EIP --> Internet
    IGW --> Internet

    ALB_Ext ==> PS1
    EKS_Int ==> PVS1
```

---

## Key Features

| Feature              | Implementation                                  | Reference |
| -------------------- | ----------------------------------------------- | --------- |
| **VPC CIDR**         | Configurable via `var.vpc_cidr`                 | §51       |
| **3 AZs**            | Subnets distributed across 3 availability zones | §55       |
| **Public Subnets**   | Map public IP on launch enabled                 | §56       |
| **Private Subnets**  | Isolated from direct internet access            | §56       |
| **Internet Gateway** | Provides internet access for public subnets     | §57       |
| **NAT Gateway**      | Enables outbound internet for private subnets   | §57       |
| **Route Tables**     | Separate public and private routing             | §57       |

---

_Generated from: terraform/modules/vpc/main.tf_
