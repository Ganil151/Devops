# 04. Gateway Load Balancer (GWLB)
# Used for deploying and managing a fleet of third-party virtual appliances (firewalls, IDS/IPS).

resource "aws_lb" "gwlb" {
  name               = "security-appliance-lb"
  load_balancer_type = "gateway"
  subnets            = var.private_subnet_ids

  tags = {
    Name = "Security-GWLB"
  }
}
