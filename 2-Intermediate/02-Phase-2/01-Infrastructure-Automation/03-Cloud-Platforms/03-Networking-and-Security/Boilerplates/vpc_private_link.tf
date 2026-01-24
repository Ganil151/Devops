# Cloud Security Boilerplate: VPC Interface Endpoint (PrivateLink)

/* 
   This configuration allows a private EC2 instance to talk to Amazon S3 
   WITHOUT ever crossing the public internet or needing a NAT Gateway.
*/

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-east-1.s3"
  
  # Type: Gateway (S3 and DynamoDB) or Interface (Everything else)
  vpc_endpoint_type = "Gateway"

  # Link to the Route Tables of your PRIVATE subnets
  route_table_ids = [aws_route_table.private_rt.id]

  tags = {
    Name        = "S3-Private-Link"
    Environment = "production"
  }
}

---

# Pro-Tip: Security Group "Source" Pattern
Instead of:
`cidr_blocks = ["10.0.1.0/24"]`
Use:
`security_groups = ["sg-12345678"]`
This ensures that ONLY instances with that specific membership can talk, even if the IP addresses change.
