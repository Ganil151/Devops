# 16. NLB with Elastic IP
# Providing a fixed public IP address for the network load balancer.

resource "aws_lb" "nlb_with_eip" {
  name               = "fixed-ip-nlb"
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id     = var.public_subnet_az1_id
    allocation_id = var.eip_az1_id
  }

  subnet_mapping {
    subnet_id     = var.public_subnet_az2_id
    allocation_id = var.eip_az2_id
  }
}
# (Elastic IPs are assigned per Availability Zone)
