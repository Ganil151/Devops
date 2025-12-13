# Infrastructure as Code (IaC)

Comprehensive guide to Infrastructure as Code across cloud platforms using Terraform, CloudFormation, and other tools.

## Terraform Multi-Cloud
```hcl
# main.tf - Multi-cloud infrastructure
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

# AWS Provider
provider "aws" {
  region = var.aws_region
}

# Azure Provider
provider "azurerm" {
  features {}
}

# GCP Provider
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

# AWS VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "main-vpc"
    Environment = var.environment
  }
}

# Azure Resource Group and VNet
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.environment}"
  location = var.azure_location
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.environment}"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# GCP VPC
resource "google_compute_network" "main" {
  name                    = "vpc-${var.environment}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = "subnet-${var.environment}"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.gcp_region
  network       = google_compute_network.main.id
}
```

## AWS CloudFormation
```yaml
# cloudformation-template.yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Multi-tier web application infrastructure'

Parameters:
  Environment:
    Type: String
    Default: production
    AllowedValues: [development, staging, production]
  
  InstanceType:
    Type: String
    Default: t3.medium
    AllowedValues: [t3.micro, t3.small, t3.medium, t3.large]

Resources:
  # VPC
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-vpc'

  # Internet Gateway
  InternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-igw'

  # Attach Gateway to VPC
  AttachGateway:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref VPC
      InternetGatewayId: !Ref InternetGateway

  # Public Subnet
  PublicSubnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.1.0/24
      AvailabilityZone: !Select [0, !GetAZs '']
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-public-subnet'

  # Route Table
  PublicRouteTable:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-public-rt'

  # Route to Internet
  PublicRoute:
    Type: AWS::EC2::Route
    DependsOn: AttachGateway
    Properties:
      RouteTableId: !Ref PublicRouteTable
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref InternetGateway

  # Associate Route Table
  PublicSubnetRouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref PublicSubnet
      RouteTableId: !Ref PublicRouteTable

  # Security Group
  WebServerSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security group for web servers
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0

  # Launch Template
  LaunchTemplate:
    Type: AWS::EC2::LaunchTemplate
    Properties:
      LaunchTemplateName: !Sub '${Environment}-web-template'
      LaunchTemplateData:
        ImageId: ami-0abcdef1234567890
        InstanceType: !Ref InstanceType
        SecurityGroupIds:
          - !Ref WebServerSecurityGroup
        UserData:
          Fn::Base64: !Sub |
            #!/bin/bash
            yum update -y
            yum install -y httpd
            systemctl start httpd
            systemctl enable httpd
            echo "<h1>Web Server in ${Environment}</h1>" > /var/www/html/index.html

  # Auto Scaling Group
  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      LaunchTemplate:
        LaunchTemplateId: !Ref LaunchTemplate
        Version: !GetAtt LaunchTemplate.LatestVersionNumber
      MinSize: 2
      MaxSize: 10
      DesiredCapacity: 3
      VPCZoneIdentifier:
        - !Ref PublicSubnet
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-web-server'
          PropagateAtLaunch: true

Outputs:
  VPCId:
    Description: VPC ID
    Value: !Ref VPC
    Export:
      Name: !Sub '${Environment}-VPC-ID'
  
  PublicSubnetId:
    Description: Public Subnet ID
    Value: !Ref PublicSubnet
    Export:
      Name: !Sub '${Environment}-PublicSubnet-ID'
```

## Azure Resource Manager (ARM)
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "environment": {
      "type": "string",
      "defaultValue": "production",
      "allowedValues": ["development", "staging", "production"]
    },
    "vmSize": {
      "type": "string",
      "defaultValue": "Standard_B2s",
      "allowedValues": ["Standard_B1s", "Standard_B2s", "Standard_D2s_v3"]
    }
  },
  "variables": {
    "vnetName": "[concat('vnet-', parameters('environment'))]",
    "subnetName": "[concat('subnet-', parameters('environment'))]",
    "nsgName": "[concat('nsg-', parameters('environment'))]",
    "vmssName": "[concat('vmss-', parameters('environment'))]"
  },
  "resources": [
    {
      "type": "Microsoft.Network/virtualNetworks",
      "apiVersion": "2021-02-01",
      "name": "[variables('vnetName')]",
      "location": "[resourceGroup().location]",
      "properties": {
        "addressSpace": {
          "addressPrefixes": ["10.0.0.0/16"]
        },
        "subnets": [
          {
            "name": "[variables('subnetName')]",
            "properties": {
              "addressPrefix": "10.0.1.0/24"
            }
          }
        ]
      }
    },
    {
      "type": "Microsoft.Network/networkSecurityGroups",
      "apiVersion": "2021-02-01",
      "name": "[variables('nsgName')]",
      "location": "[resourceGroup().location]",
      "properties": {
        "securityRules": [
          {
            "name": "AllowHTTP",
            "properties": {
              "protocol": "Tcp",
              "sourcePortRange": "*",
              "destinationPortRange": "80",
              "sourceAddressPrefix": "*",
              "destinationAddressPrefix": "*",
              "access": "Allow",
              "priority": 1000,
              "direction": "Inbound"
            }
          }
        ]
      }
    },
    {
      "type": "Microsoft.Compute/virtualMachineScaleSets",
      "apiVersion": "2021-03-01",
      "name": "[variables('vmssName')]",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[resourceId('Microsoft.Network/virtualNetworks', variables('vnetName'))]",
        "[resourceId('Microsoft.Network/networkSecurityGroups', variables('nsgName'))]"
      ],
      "sku": {
        "name": "[parameters('vmSize')]",
        "capacity": 3
      },
      "properties": {
        "upgradePolicy": {
          "mode": "Automatic"
        },
        "virtualMachineProfile": {
          "storageProfile": {
            "imageReference": {
              "publisher": "Canonical",
              "offer": "UbuntuServer",
              "sku": "18.04-LTS",
              "version": "latest"
            }
          },
          "osProfile": {
            "computerNamePrefix": "[variables('vmssName')]",
            "adminUsername": "azureuser",
            "customData": "[base64('#!/bin/bash\napt-get update\napt-get install -y nginx\nsystemctl start nginx\nsystemctl enable nginx')]"
          },
          "networkProfile": {
            "networkInterfaceConfigurations": [
              {
                "name": "nicConfig",
                "properties": {
                  "primary": true,
                  "ipConfigurations": [
                    {
                      "name": "ipConfig",
                      "properties": {
                        "subnet": {
                          "id": "[resourceId('Microsoft.Network/virtualNetworks/subnets', variables('vnetName'), variables('subnetName'))]"
                        }
                      }
                    }
                  ],
                  "networkSecurityGroup": {
                    "id": "[resourceId('Microsoft.Network/networkSecurityGroups', variables('nsgName'))]"
                  }
                }
              }
            ]
          }
        }
      }
    }
  ],
  "outputs": {
    "vnetId": {
      "type": "string",
      "value": "[resourceId('Microsoft.Network/virtualNetworks', variables('vnetName'))]"
    }
  }
}
```

## Pulumi (Programming Languages)
```python
# pulumi_infrastructure.py
import pulumi
import pulumi_aws as aws
import pulumi_azure_native as azure
import pulumi_gcp as gcp

# Configuration
config = pulumi.Config()
environment = config.get("environment", "production")

# AWS Infrastructure
aws_vpc = aws.ec2.Vpc(
    f"vpc-{environment}",
    cidr_block="10.0.0.0/16",
    enable_dns_hostnames=True,
    enable_dns_support=True,
    tags={"Name": f"vpc-{environment}"}
)

aws_subnet = aws.ec2.Subnet(
    f"subnet-{environment}",
    vpc_id=aws_vpc.id,
    cidr_block="10.0.1.0/24",
    map_public_ip_on_launch=True,
    tags={"Name": f"subnet-{environment}"}
)

# Azure Infrastructure
azure_rg = azure.resources.ResourceGroup(
    f"rg-{environment}",
    resource_group_name=f"rg-{environment}",
    location="East US"
)

azure_vnet = azure.network.VirtualNetwork(
    f"vnet-{environment}",
    resource_group_name=azure_rg.name,
    virtual_network_name=f"vnet-{environment}",
    location=azure_rg.location,
    address_space=azure.network.AddressSpaceArgs(
        address_prefixes=["10.1.0.0/16"]
    )
)

# GCP Infrastructure
gcp_network = gcp.compute.Network(
    f"network-{environment}",
    name=f"network-{environment}",
    auto_create_subnetworks=False
)

gcp_subnet = gcp.compute.Subnetwork(
    f"subnet-{environment}",
    name=f"subnet-{environment}",
    ip_cidr_range="10.2.0.0/16",
    region="us-central1",
    network=gcp_network.id
)

# Exports
pulumi.export("aws_vpc_id", aws_vpc.id)
pulumi.export("azure_vnet_id", azure_vnet.id)
pulumi.export("gcp_network_id", gcp_network.id)
```

This guide covers Infrastructure as Code implementation across multiple cloud platforms using various tools and frameworks.