# VPC Peering Guide

> **Note**: This is an Intermediate-level topic.

## What is VPC Peering?
VPC Peering is a networking connection between two VPCS that enables you to route traffic between them using private IPv4 addresses. Instances in either VPC can communicate with each other as if they are within the same network.

## Key Concepts
- **Non-Transitive**: If A peers with B, and B peers with C, A cannot talk to C.
- **No Overlapping CIDRs**: You cannot peer VPCs with matching IP ranges (e.g., both 10.0.0.0/16).
- **Same or Different Account/Region**: You can peer across AWS accounts and regions.

## Setup Steps
1.  **Request**: Requester VPC sends a peering request to Accepter VPC.
2.  **Accept**: Accepter (owner) accepts the request.
3.  **Route**: **Crucial Step** - Update Route Tables in BOTH VPCs to point to the Peering Connection (pcx-xxxx).
    - VPC A Route Table: `Dest: VPC-B-CIDR -> Target: pcx-ID`
    - VPC B Route Table: `Dest: VPC-A-CIDR -> Target: pcx-ID`
4.  **Security Groups**: Update SGs to allow traffic from the peer VPC CIDR.
