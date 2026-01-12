## Permissions:
ec2:DeleteVpc: Allows the deletion of the VPC itself.
ec2:DescribeVpcs: Allows viewing information about VPCs, which can be helpful for identifying the correct VPC and its dependencies.
ec2:TerminateInstances: Allows terminating EC2 instances running within the VPC.
ec2:DeleteSubnet: Allows deleting subnets within the VPC.
ec2:DeleteInternetGateway, ec2:DetachInternetGateway: Allows deleting and detaching internet gateways associated with the VPC.
ec2:DeleteRouteTable, ec2:DisassociateRouteTable: Allows deleting and disassociating route tables.
ec2:DeleteNetworkAcl, ec2:DisassociateNetworkAcl: Allows deleting and disassociating network ACLs.
ec2:DeleteSecurityGroup: Allows deleting security groups.
ec2:ReleaseAddress, ec2:DisassociateAddress: Allows releasing and disassociating Elastic IP addresses.
ec2:DeleteVpcPeeringConnection: Allows deleting VPC peering connections.
ec2:DeleteNatGateway: Allows deleting NAT Gateways.
ec2:DeleteVpnConnection, ec2:DeleteVpnGateway, ec2:DeleteCustomerGateway: Allows deleting VPN-related resources.
ec2:DeleteDhcpOptions: Allows deleting custom DHCP option sets.
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DeleteVpc",
                "ec2:DescribeVpcs",
                "ec2:TerminateInstances",
                "ec2:DeleteSubnet",
                "ec2:DeleteInternetGateway",
                "ec2:DetachInternetGateway",
                "ec2:DeleteRouteTable",
                "ec2:DisassociateRouteTable",
                "ec2:DeleteNetworkAcl",
                "ec2:DisassociateNetworkAcl",
                "ec2:DeleteSecurityGroup",
                "ec2:ReleaseAddress",
                "ec2:DisassociateAddress",
                "ec2:DeleteVpcPeeringConnection",
                "ec2:DeleteNatGateway",
                "ec2:DeleteVpnConnection",
                "ec2:DeleteVpnGateway",
                "ec2:DeleteCustomerGateway",
                "ec2:DeleteDhcpOptions"
            ],
            "Resource": "*"
        }
    ]
}
```

Identify and Delete Network Interfaces
The error indicates that the subnets contain network interfaces (eni-0ca453ae657713226), which are preventing the deletion of the subnets. These network interfaces are likely associated with resources like EC2 instances, Kubernetes nodes, or other AWS services.

Steps:
List Network Interfaces:
Run the following AWS CLI command to list all network interfaces in the VPC:
```bash
aws ec2 describe-network-interfaces --filters "Name=vpc-id,Values=vpc-04a21b0ab2ba29a24"
```

This will show details about the network interfaces, including their attachment status.
Detach and Delete Network Interfaces:
If the network interfaces are attached to any resource (e.g., EC2 instances, EKS worker nodes), detach them first:
```bash
aws ec2 detach-network-interface --attachment-id <attachment-id>
```

Once detached, delete the network interface:
```bash
aws ec2 delete-network-interface --network-interface-id eni-0ca453ae657713226
```

If the network interface cannot be deleted because it is "in use," ensure that no hidden resources (e.g., EKS worker nodes, NAT gateways) are still referencing it.
2. Check for Hidden Resources
Even if you don't see explicit resources like ELBs or IGWs, there might still be hidden dependencies such as:

EKS Worker Nodes: If you previously created an EKS cluster, worker nodes might still exist.
NAT Gateways: These often create network interfaces.
Security Groups: Ensure no security groups are tied to the subnets.
Steps:
Check for EKS Clusters:
List all EKS clusters:
```bash
aws eks list-clusters
```

Check for NAT Gateways:
List NAT gateways in the VPC:
```bash
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=vpc-04a21b0ab2ba29a24"
```

If any NAT gateways exist, delete them:
```bash
aws ec2 delete-nat-gateway --nat-gateway-id <nat-gateway-id>
```

. Delete Route Tables
The error indicates that the route table (rtb-0df50755efa22c330) is the main route table for the VPC, which cannot be deleted directly.

Steps:
Disassociate Subnets from the Route Table:
List all route tables and their associations:
bash


1
aws ec2 describe-route-tables --route-table-id rtb-0df50755efa22c330
Disassociate subnets from the route table:
bash


1
aws ec2 disassociate-route-table --association-id <association-id>
Delete Non-Main Route Tables:
After disassociating subnets, delete non-main route tables:
```bash
aws ec2 delete-route-table --route-table-id rtb-0df50755efa22c330
```

 Delete Network ACLs
Default network ACLs (acl-06fd188bbe56c93e1) cannot be deleted unless they are replaced with custom ones.

Steps:
Replace Default Network ACL:
Create a new custom network ACL:
```bash
aws ec2 create-network-acl --vpc-id vpc-04a21b0ab2ba29a24
```

Associate subnets with the new network ACL:
```bash
aws ec2 replace-network-acl-association --association-id <association-id> --network-acl-id <new-acl-id>
```

Delete the default network ACL:
```bash
aws ec2 delete-network-acl --network-acl-id acl-06fd188bbe56c93e1
```

 Delete Subnets
Once all dependencies are removed, you can delete the subnets.

Steps:
Delete Subnets:
Use the following command to delete each subnet:
```bash
aws ec2 delete-subnet --subnet-id subnet-0876d04d6b99eb21a
aws ec2 delete-subnet --subnet-id subnet-0f93c14a3c92fd3f5
```

Delete the VPC
Finally, after deleting all subnets, route tables, network ACLs, and other resources, you can delete the VPC.

Steps:
```bash
aws ec2 delete-vpc --vpc-id vpc-04a21b0ab2ba29a24
```

Verify IAM Permissions
Ensure that the IAM user or role you are using has the required permissions for EC2 actions, including ec2:DetachNetworkInterface.

Example IAM Policy:
You need to attach a policy with the following permissions to your IAM user or role:
```bash 
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DetachNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": "*"
    }
  ]
}
```

```bash
aws ec2 detach-network-interface --attachment-id eni-attach-0a28bfc90a75dd54e --region us-east-1
```

Debugging with aws sts get-caller-identity
Run the following command to confirm which IAM user or role you are currently authenticated as:
```bash
aws sts get-caller-identity
```

Retry Detaching the Network Interface
Once you have verified and updated the permissions, retry detaching the network interface:
```bash
aws ec2 detach-network-interface --attachment-id eni-attach-0a28bfc90a75dd54e
```

Delete the Network Interface
After detaching the network interface, you can delete it using the following command:
```bash
aws ec2 delete-network-interface --network-interface-id eni-0ca453ae657713226
```

Automating Permission Updates (Optional)
If you frequently encounter permission issues, 
consider automating IAM policy updates using tools like Terraform or AWS CloudFormation. 
Here’s an example Terraform snippet to add the required permissions:
```bash
resource "aws_iam_policy" "ec2_detach_policy" {
  name        = "EC2DetachPolicy"
  description = "Policy to allow detaching and deleting network interfaces"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DetachNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_policy" {
  user       = "your-iam-user"
  policy_arn = aws_iam_policy.ec2_detach_policy.arn
}
```
