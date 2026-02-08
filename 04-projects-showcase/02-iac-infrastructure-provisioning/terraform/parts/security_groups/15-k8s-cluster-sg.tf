# 15. Kubernetes Cluster Security Group
# Core ports for a K8s control plane or worker nodes.

resource "aws_security_group" "k8s_sg" {
  name        = "k8s-cluster-sg"
  description = "Allows K8s internal and API communication"
  vpc_id      = var.vpc_id

  ingress {
    description = "K8s API Server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "Kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "K8s-Cluster-SG"
  }
}
