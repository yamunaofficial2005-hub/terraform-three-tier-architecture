
# VPC ID
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.my_vpc.id
}

# Public subnet IDs
output "public_subnet_ids" {
  description = "IDs of public subnets for ALB"
  value       = aws_subnet.pubsubnet1[*].id
}

# Private subnet IDs
output "private_subnet_ids" {
  description = "IDs of private subnets for EC2 and RDS"
  value       = aws_subnet.prisubnet[*].id
}

# NAT Gateway ID
output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}

# NAT Gateway public IP
output "nat_public_ip" {
  description = "Elastic IP of NAT Gateway"
  value       = aws_eip.nat.public_ip
}

# ALB Security Group ID
output "alb_security_group_id" {
  description = "Security Group ID for ALB"
  value       = aws_security_group.alb_sg.id
}

# Application Security Group ID
output "app_security_group_id" {
  description = "Security Group ID for application EC2"
  value       = aws_security_group.app_sg.id
}

# Database Security Group ID
output "db_security_group_id" {
  description = "Security Group ID for RDS"
  value       = aws_security_group.db_sg.id
}
