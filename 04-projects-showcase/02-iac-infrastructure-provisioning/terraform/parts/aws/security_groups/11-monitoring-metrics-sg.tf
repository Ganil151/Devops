# 11. Monitoring and Metrics Security Group
# Allows ports for Prometheus and other exporters.

resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring-metrics-sg"
  description = "Allows scraping of metrics"
  vpc_id      = var.vpc_id

  ingress {
    description = "Prometheus Exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Internal VPC range
  }

  ingress {
    description = "Node Exporter"
    from_port   = 9090
    to_port     = 9090
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
    Name = "Monitoring-Metrics-SG"
  }
}
