# 07. Transit VPC
# Acts as a hub to connect multiple VPCs and on-premises networks.

resource "aws_vpc" "transit_hub" {
  cidr_block = "10.255.0.0/16"
  
  tags = {
    Name = "Transit-Hub-VPC"
  }
}

resource "aws_ec2_transit_gateway" "main" {
  description = "Main Transit Gateway for Hub-and-Spoke"
  
  tags = {
    Name = "Organization-TGW"
  }
}

# Attachment of the hub VPC to the TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "hub_attachment" {
  subnet_ids         = [aws_subnet.hub_subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.transit_hub.id
}

resource "aws_subnet" "hub_subnet" {
  vpc_id     = aws_vpc.transit_hub.id
  cidr_block = "10.255.1.0/24"
  
  tags = {
    Name = "TGW-Attachment-Subnet"
  }
}
