# VPC Module

## Overview

Creates a Virtual Private Cloud (VPC) with public and private subnets across multiple availability zones, including Internet Gateway, NAT Gateway, route tables, and Network ACLs for a complete network infrastructure.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         VPC (10.0.0.0/16)                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Public Subnets (AZ-a, AZ-b, AZ-c)          │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │   │
│  │  │   IGW       │  │  EIP        │  │  NAT GW     │    │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘    │   │
│  │       │                                  │             │   │
│  │  ┌────┴────┐                        ┌────┴────┐       │   │
│  │  │Public   │◄─── Route Table ──────│Private  │       │   │
│  │  │Route    │  0.0.0.0/0 → IGW      │Route    │       │   │
│  │  └─────────┘                        └────┬────┘       │   │
│  │                                           │             │   │
│  └───────────────────────────────────────────┼─────────────┘   │
│                                              │                 │
│  ┌───────────────────────────────────────────┼─────────────┐   │
│  │              Private Subnets (AZ-a, AZ-b, AZ-c)        │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │   │
│  │  │EKS Nodes    │  │  Services   │  │  Database   │    │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘    │   │
│  │                                                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Network ACLs (Public & Private)             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Section-by-Section Explanation

### 1. Availability Zones Data Source

**Purpose**: Retrieves a list of available AWS Availability Zones in the region.

```hcl
data "aws_availability_zones" "available" {
  state = "available"
}
```

- **Why**: Ensures subnets are created in valid, available AZs
- **Usage**: Used implicitly by the module to validate AZ selection

---

### 2. VPC Main Module

**Purpose**: Creates the foundation virtual network with DNS support enabled.

```hcl
resource "aws_vpc" "finishline_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  ...
}
```

| Setting                | Value       | Purpose                               |
| ---------------------- | ----------- | ------------------------------------- |
| `cidr_block`           | 10.0.0.0/16 | Private IP range for all resources    |
| `enable_dns_hostnames` | true        | Allows instances to get DNS hostnames |
| `enable_dns_support`   | true        | Enables DNS resolution within VPC     |

- **Why**: DNS support is required for EKS cluster communication and internal service discovery

---

### 3. Internet Gateway Module

**Purpose**: Provides connectivity between the VPC and the internet.

```hcl
resource "aws_internet_gateway" "finishline_igw" {
  vpc_id = aws_vpc.finishline_vpc.id
  ...
}
```

- **Why**: Required for public subnets to access the internet and for internet traffic to reach public resources
- **Usage**: Attached to public route table for outbound internet access

---

### 4. Elastic IP Module

**Purpose**: Allocates a static public IP address for the NAT Gateway.

```hcl
resource "aws_eip" "finishline_eip" {
  domain = "vpc"
  ...
}
```

- **Why**: NAT Gateway requires a persistent public IP that survives gateway recreation
- **Domain**: Set to "vpc" to ensure the EIP is associated with the VPC (not EC2-Classic)

---

### 5. Public Subnet & Route Table Module

**Purpose**: Creates subnets with direct internet access and routes for public traffic.

```hcl
resource "aws_subnet" "finishline_public_subnet" {
  count             = length(var.public_subnet_cidr)
  vpc_id            = aws_vpc.finishline_vpc.id
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
    Name = "...-public-subnet-${count.index + 1}"
    Type = "Public"
  }
}

resource "aws_route_table" "finishline_public_route_table" {
  vpc_id = aws_vpc.finishline_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.finishline_igw.id
  }
  ...
}
```

- **Why Public Subnets**:
  - Host jump host/bastion for administrative access
  - Host NAT Gateway for outbound traffic
  - Host ALB for incoming application traffic
- **Route Table**: Routes all outbound traffic (0.0.0.0/0) through the Internet Gateway

---

### 6. Private Subnet & Route Table Module

**Purpose**: Creates isolated subnets for application workloads without direct internet access.

```hcl
resource "aws_subnet" "finishline_private_subnet" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.finishline_vpc.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
    Name = "...-private-subnet-${count.index + 1}"
    Type = "Private"
    # EKS cluster tagging requirement
    "kubernetes.io/cluster/${var.project_name}-${var.environment}-eks" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_route_table" "finishline_private_route_table" {
  vpc_id = aws_vpc.finishline_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.finishline_nat_gateway.id
  }
  ...
}
```

- **Why Private Subnets**:
  - Host EKS worker nodes for security
  - Host databases and internal services
  - No direct internet access (security best practice)
- **EKS Tags Required**:
  - `kubernetes.io/cluster/<name>` = "shared" - Allows EKS to use subnets for load balancers
  - `kubernetes.io/role/internal-elb` = "1" - Enables internal load balancers in these subnets

---

### 7. NAT Gateway Module

**Purpose**: Provides outbound internet access for private subnets while preventing inbound internet access.

```hcl
resource "aws_nat_gateway" "finishline_nat_gateway" {
  allocation_id = aws_eip.finishline_eip.id
  subnet_id     = aws_subnet.finishline_public_subnet[0].id
  ...
}
```

- **Why**:
  - Private subnets need internet access for package updates, API calls, etc.
  - NAT Gateway allows outbound connections but blocks unsolicited inbound connections
  - Provides network address translation (NAT)
- **Placement**: Deployed in public subnet but acts as a gateway for private subnets

---

### 8. Network ACL - Public Subnets

**Purpose**: Adds an additional layer of security at the subnet boundary for public subnets.

```hcl
resource "aws_network_acl" "finishline_public_nacl" {
  vpc_id     = aws_vpc.finishline_vpc.id
  subnet_ids = aws_subnet.finishline_public_subnet[*].id

  # Ingress Rules
  ingress { protocol = "tcp", from_port = 80, to_port = 80, cidr_block = "0.0.0.0/0", action = "allow" }   # HTTP
  ingress { protocol = "tcp", from_port = 443, to_port = 443, cidr_block = "0.0.0.0/0", action = "allow" } # HTTPS
  ingress { protocol = "tcp", from_port = 22, to_port = 22, cidr_block = "0.0.0.0/0", action = "allow" }   # SSH
  ingress { protocol = "tcp", from_port = 1024, to_port = 65535, cidr_block = "0.0.0.0/0", action = "allow" } # Ephemeral ports

  # Egress Rules
  egress { protocol = "-1", from_port = 0, to_port = 0, cidr_block = "0.0.0.0/0", action = "allow" }  # All traffic
}
```

| Port       | Protocol | Source    | Purpose                            |
| ---------- | -------- | --------- | ---------------------------------- |
| 80         | TCP      | 0.0.0.0/0 | HTTP web traffic                   |
| 443        | TCP      | 0.0.0.0/0 | HTTPS encrypted web traffic        |
| 22         | TCP      | 0.0.0.0/0 | SSH administrative access          |
| 1024-65535 | TCP      | 0.0.0.0/0 | Ephemeral ports for return traffic |

- **Why**: Stateful firewall layer in addition to Security Groups
- **Rule Numbering**: Lower numbers are processed first (100, 110, 120, 130)

---

### 9. Network ACL - Private Subnets

**Purpose**: Adds security layer for private subnets restricting inbound traffic.

```hcl
resource "aws_network_acl" "finishline_private_nacl" {
  vpc_id     = aws_vpc.finishline_vpc.id
  subnet_ids = aws_subnet.finishline_private_subnet[*].id

  # Ingress Rules
  ingress { protocol = "tcp", from_port = 0, to_port = 65535, cidr_block = var.vpc_cidr, action = "allow" }  # Internal traffic
  ingress { protocol = "tcp", from_port = 1024, to_port = 65535, cidr_block = "0.0.0.0/0", action = "allow" } # Return traffic

  # Egress Rules
  egress { protocol = "-1", from_port = 0, to_port = 0, cidr_block = "0.0.0.0/0", action = "allow" }  # All outbound
}
```

| Port       | Protocol | Source    | Purpose                         |
| ---------- | -------- | --------- | ------------------------------- |
| 0-65535    | TCP      | VPC CIDR  | All internal traffic within VPC |
| 1024-65535 | TCP      | 0.0.0.0/0 | Return traffic from NAT Gateway |

- **Why**:
  - Restricts direct internet access to private subnets
  - Only from within the VPC or established allows traffic originating connections through NAT

---

## Inputs

| Variable               | Description                                   | Type         | Default |
| ---------------------- | --------------------------------------------- | ------------ | ------- |
| `project_name`         | The name of the project                       | string       | ""      |
| `environment`          | The environment name (dev, staging, prod)     | string       | ""      |
| `managedBy`            | The team or individual managing the resources | string       | ""      |
| `aws_region`           | The AWS region                                | string       | ""      |
| `vpc_cidr`             | The CIDR block for the VPC                    | string       | ""      |
| `enable_dns_support`   | Whether to enable DNS support                 | bool         | true    |
| `enable_dns_hostnames` | Whether to enable DNS hostnames               | bool         | true    |
| `availability_zone`    | List of AZs for subnet distribution           | list(string) | []      |
| `public_subnet_cidr`   | List of public subnet CIDR blocks             | list(string) | []      |
| `private_subnet_cidr`  | List of private subnet CIDR blocks            | list(string) | []      |
| `additional_tags`      | Additional tags for the resources             | map(string)  | {}      |

## Outputs

| Output                   | Description                |
| ------------------------ | -------------------------- |
| `vpc_id`                 | VPC identifier             |
| `vpc_arn`                | VPC ARN                    |
| `vpc_cidr`               | VPC CIDR block             |
| `aws_region`             | AWS region                 |
| `enable_dns_support`     | DNS support status         |
| `enable_dns_hostnames`   | DNS hostnames status       |
| `availability_zone`      | List of availability zones |
| `public_subnet_id`       | List of public subnet IDs  |
| `private_subnet_id`      | List of private subnet IDs |
| `nat_gateway_id`         | NAT Gateway ID             |
| `internet_gateway_id`    | Internet Gateway ID        |
| `eip_id`                 | Elastic IP ID              |
| `public_route_table_id`  | Public route table ID      |
| `private_route_table_id` | Private route table ID     |
| `public_nacl_id`         | Public network ACL ID      |
| `private_nacl_id`        | Private network ACL ID     |

## Connections

- **Depends on**: None (foundational module - must be deployed first)
- **Used by**:
  - Security Group module (requires `vpc_id`)
  - EKS module (requires `private_subnet_id`, `public_subnet_id`)
  - Bootstrap module (requires `public_subnet_id`)
  - ALB module (requires `vpc_id`, `subnet_ids`)
- **Provides**: Complete network foundation for all infrastructure

## Best Practices Implemented

- ✅ Multi-AZ deployment for high availability
- ✅ Public/private subnet separation
- ✅ NAT Gateway for private subnet internet access
- ✅ EKS-required subnet tags for load balancers
- ✅ Network ACLs as additional security layer
- ✅ Consistent tagging for resource management
- ✅ DNS hostnames and support enabled
