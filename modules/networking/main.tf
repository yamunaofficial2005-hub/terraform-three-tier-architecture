
# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-${var.project_name}-vpc"
  }
}

# Create 2 public subnets
resource "aws_subnet" "pubsubnet1" {
  count = 2

  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 8, count.index)

  availability_zone = [
    "ap-south-1a",
    "ap-south-1b"
  ][count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "my-publicsubnet-${count.index + 1}"
  }
}

# Create 4 private subnets
resource "aws_subnet" "prisubnet" {
  count = 4

  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 8, count.index + 2)

  availability_zone = [
    "ap-south-1a",
    "ap-south-1b"
  ][count.index % 2]

  tags = {
    Name = "my-privatesubnet-${count.index + 1}"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-${var.project_name}-igw"
  }
}

# Create public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "route_pubsub" {
  count = length(aws_subnet.pubsubnet1)

  subnet_id      = aws_subnet.pubsubnet1[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "my-${var.project_name}-nat-eip"
  }
}

# Create NAT Gateway in public subnet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.pubsubnet1[0].id

  depends_on = [
    aws_internet_gateway.igw
  ]

  tags = {
    Name = "my-${var.project_name}-nat"
  }
}

# Create private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "private-rt"
  }
}

# Route private subnet outbound traffic through NAT
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private_assoc" {
  count = length(aws_subnet.prisubnet)

  subnet_id      = aws_subnet.prisubnet[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow HTTP and HTTPS traffic to ALB"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# Application Security Group
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-app-sg"
  description = "Allow application traffic from ALB only"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}

# Database Security Group
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Allow MySQL from application tier only"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description     = "MySQL from application tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}
