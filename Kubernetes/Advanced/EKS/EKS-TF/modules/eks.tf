resource "aws_eks_cluster" "eks" {
  count    = var.is_eks_cluster_enabled ? 1 : 0
  name     = var.cluster_name
  role_arn = aws_iam_role.eks-cluster-role[0].arn
  version  = var.cluster-version

  vpc_config {
    subnet_ids              = [aws_subnet.private-subnet[0].id, aws_subnet.private-subnet[1].id, aws_subnet.private-subnet[2].id]
    endpoint_private_access = var.endpoint-private-access
    endpoint_public_access  = var.endpoint-public-access
    security_group_ids      = [aws_security_group.eks-cluster-sg.id]
  }

  access_config {
    authentication_mode                         = "CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = {
    Name = var.cluster_name
    Env  = var.env
  }
}

# OIDC Provider
resource "aws_iam_openid_connect_provider" "eks-oidc-provider" {
  # Add count here so it matches the cluster enablement
  count = var.is_eks_cluster_enabled ? 1 : 0

  client_id_list  = ["sts.amazonaws.com"]
  
  # FIX: Added [0] index to the data source reference
  thumbprint_list = [data.tls_certificate.eks-certificate[0].certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.eks-certificate[0].url
}

# AddOns for EKS Cluster
resource "aws_eks_addon" "eks-addons" {
  for_each = var.is_eks_cluster_enabled ? { for idx, addon in var.addons : idx => addon } : {}
  
  cluster_name  = aws_eks_cluster.eks[0].name
  addon_name    = each.value.name
  addon_version = each.value.version

  depends_on = [aws_eks_node_group.ondemand-node, aws_eks_node_group.spot-node]
}

# NodeGroup - On-Demand
resource "aws_eks_node_group" "ondemand-node" {
  count           = var.is_eks_cluster_enabled ? 1 : 0
  cluster_name    = aws_eks_cluster.eks[0].name
  node_group_name = "${var.cluster_name}-on-demand-nodes"

  node_role_arn = aws_iam_role.eks-nodegroup-role[0].arn

  scaling_config {
    desired_size = var.desired_capacity_on_demand
    min_size     = var.min_capacity_on_demand
    max_size     = var.max_capacity_on_demand
  }

  subnet_ids = [aws_subnet.private-subnet[0].id, aws_subnet.private-subnet[1].id, aws_subnet.private-subnet[2].id]

  instance_types = var.ondemand_instance_types
  capacity_type  = "ON_DEMAND"
  
  labels = {
    type = "ondemand"
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name = "${var.cluster_name}-on-demand-nodes"
    Env  = var.env
  }

  tags_all = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "Name"                                      = "${var.cluster_name}-on-demand-nodes"
  }

  depends_on = [aws_eks_cluster.eks]
}

# NodeGroup - Spot
resource "aws_eks_node_group" "spot-node" {
  count           = var.is_eks_cluster_enabled ? 1 : 0
  cluster_name    = aws_eks_cluster.eks[0].name
  node_group_name = "${var.cluster_name}-spot-nodes"

  node_role_arn = aws_iam_role.eks-nodegroup-role[0].arn

  scaling_config {
    desired_size = var.desired_capacity_spot
    min_size     = var.min_capacity_spot
    max_size     = var.max_capacity_spot
  }

  subnet_ids = [aws_subnet.private-subnet[0].id, aws_subnet.private-subnet[1].id, aws_subnet.private-subnet[2].id]

  instance_types = var.spot_instance_types
  capacity_type  = "SPOT"

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name = "${var.cluster_name}-spot-nodes"
  }

  tags_all = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "Name"                                      = "${var.cluster_name}-spot-nodes"
  }

  labels = {
    type      = "spot"
    lifecycle = "spot"
  }

  disk_size = 50

  depends_on = [aws_eks_cluster.eks]
}