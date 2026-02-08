# 09. Spot Instance
# Spare capacity at deep discounts (up to 90%).

resource "aws_instance" "spot_node" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "c5.large"

  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = "0.03" # Max price willing to pay per hour
    }
  }

  tags = {
    Name = "Cost-Effective-Spot-Worker"
  }
}
