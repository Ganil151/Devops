# 17. Cross-Zone Load Balancing Configuration
# distributes traffic evenly across all instances in all enabled Availability Zones.

resource "aws_lb" "cross_zone_lb" {
  name               = "cross-zone-enabled-lb"
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids

  enable_cross_zone_load_balancing = true
}
