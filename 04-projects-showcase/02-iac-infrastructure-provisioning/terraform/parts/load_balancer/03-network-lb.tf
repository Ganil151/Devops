# 03. Network Load Balancer (NLB)
# High-performance L4 load balancer for TCP/UDP traffic.

resource "aws_lb" "public_nlb" {
  name               = "public-network-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids

  enable_cross_zone_load_balancing = true

  tags = {
    Name = "High-Perf-NLB"
  }
}
