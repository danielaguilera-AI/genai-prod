# ============================================================
# VPC CREATION
# ============================================================
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"  # Defines the private network range
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "llm-vpc"
  }
}

# ============================================================
# INTERNET GATEWAY (Allows Public Access)
# ============================================================
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "llm-internet-gw"
  }
}

# ============================================================
# PUBLIC SUBNETS (For ECS and ALB)
# ============================================================
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "llm-public-subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "llm-public-subnet-2"
  }
}

# ============================================================
# ROUTE TABLE (Routes traffic from public subnets to the Internet)
# ============================================================
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "llm-public-route-table"
  }
}

# Associate public subnets with route table
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}
