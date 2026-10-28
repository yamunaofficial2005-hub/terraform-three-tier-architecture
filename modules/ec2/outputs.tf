
output "instance_ids" {
  description = "Application EC2 instance IDs"
  value       = aws_instance.app[*].id
}

output "private_ips" {
  description = "Private IP addresses of application servers"
  value       = aws_instance.app[*].private_ip
}
