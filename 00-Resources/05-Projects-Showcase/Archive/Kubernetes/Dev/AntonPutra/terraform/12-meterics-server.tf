resource "helm_release" "meterics_server" {
  name = "meterics-server"

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart = "meterics-server"
  namespace = "kube-system"
  version = "3.12.1"

  values = [file("${path.module}/values/meterics-server.yaml")]

  depends_on = [ aws_eks_node_group.general ]
}