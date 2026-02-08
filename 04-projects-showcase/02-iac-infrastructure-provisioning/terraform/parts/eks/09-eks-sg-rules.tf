# 09. EKS Cluster Security Group
# Adopting and tagging the security group created by EKS.

# Note: EKS automatically creates a security group.
# You can reference it using cluster.vpc_config[0].cluster_security_group_id

resource "aws_security_group_rule" "allow_cluster_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8"]
  security_group_id = aws_eks_cluster.basic.vpc_config[0].cluster_security_group_id
}
