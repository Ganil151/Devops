resource "aws_subnet" "private_zone1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/19"
  availability_zone = local.zone1

  tags = {
    Name = "${local.env}-private-${local.zone1}"
    kubernates.io/role/internal-elb = "1"
    "kubernates.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "private_zone2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.32.0/19"
  availability_zone = local.zone2

  tags = {
    Name = "${local.env}-private-${local.zone2}"
    kubernates.io/role/internal-elb = "1"
    "kubernates.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "public_zone1" {
  vpc_id = aws_subnet.main.id
  cidr_block = "10.0.64.0/19"

  tags = {
    Name = "${local.env}-public-${local.zone1}"
    kubernates.io/role/internal-elb = "1"
    "kubernates.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "public_zone2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.96.0/19"

  tags = {
    Name = "${local.env}-public-${local.zone2}"
    kubernates.io/role/internal-elb = "1"
    "kubernates.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}  
