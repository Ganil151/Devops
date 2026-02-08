# 20. Minimalist Security Group
# A starting point with no rules (default deny).

resource "aws_security_group" "minimalist" {
  name        = "minimalist-sg"
  description = "Standard starting block - deny all"
  vpc_id      = var.vpc_id

  tags = {
    Name = "Baseline-Deny-All-SG"
  }
}
