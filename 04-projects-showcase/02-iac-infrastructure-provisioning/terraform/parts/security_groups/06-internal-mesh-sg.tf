# 06. Internal Mesh Security Group
# All members of this group can talk to each other on all ports.

resource "aws_security_group" "internal_mesh" {
  name        = "internal-mesh-sg"
  description = "Allows full communication between group members"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Internal-Mesh-SG"
  }
}
