# 16. CloudFront Origin Security Group
# Restricts access to CloudFront IPs using Managed Prefix Lists.

resource "aws_security_group" "cloudfront_origin" {
  name        = "cloudfront-origin-sg"
  description = "Only allows traffic from CloudFront"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = ["pl-02cd2c6b"] # Example for CloudFront in us-east-1
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "CloudFront-Origin-SG"
  }
}
