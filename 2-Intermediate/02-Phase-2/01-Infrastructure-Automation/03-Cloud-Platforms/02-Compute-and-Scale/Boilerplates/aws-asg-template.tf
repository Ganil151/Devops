# Cloud Engineering Boilerplate: AWS ASG & Launch Template (Terraform)

# --- 1. THE LAUNCH TEMPLATE ---
resource "aws_launch_template" "app_template" {
  name_prefix   = "app-v1-"
  image_id      = "ami-0c55b159cbfafe1f0" # Amazon Linux 2023
  instance_type = "t3.micro"

  # UserData script to initialize the server
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "Server initialized at $(date)" > /var/www/html/status.txt
              EOF
  )

  monitoring {
    enabled = true # Detailed monitoring for faster scaling
  }
}

# --- 2. THE AUTO SCALING GROUP ---
resource "aws_autoscaling_group" "app_asg" {
  name                = "production-asg"
  vpc_zone_identifier = module.vpc.private_subnets
  target_group_arns   = [aws_lb_target_group.app_tg.arn]
  
  desired_capacity    = 2
  max_size            = 5
  min_size            = 2

  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "prod-app-server"
    propagate_at_launch = true
  }
}

# --- 3. SCALING POLICY ---
resource "aws_autoscaling_policy" "cpu_scaling" {
  name                   = "cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
