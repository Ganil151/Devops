# Topic: High-Availability Compute
# Description: Demonstrates an Auto-Scaling Group across multiple Availability Zones with an ALB.

provider "aws" {
  region = "us-east-1"
}

resource "aws_launch_template" "app_server" {
  name_prefix   = "app-v1-"
  image_id      = "ami-0c55b159cbfafe1f0" # Replace with actual hardened AMI
  instance_type = "t3.medium"
  
  monitoring {
    enabled = true
  }
}

resource "aws_autoscaling_group" "app_asg" {
  # 🚀 Logic: Spread nodes across 3 Availability Zones
  vpc_zone_identifier = ["subnet-123", "subnet-456", "subnet-789"]
  desired_capacity    = 3
  max_size            = 10
  min_size            = 2

  launch_template {
    id      = aws_launch_template.app_server.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300
}

resource "aws_lb" "app_alb" {
  name               = "prod-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-abc"]
  subnets            = ["subnet-123", "subnet-456", "subnet-789"]
}
