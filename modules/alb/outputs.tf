
output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.my_alb.dns_name
}

output "alb_arn" {
  value = aws_lb.my_alb.arn
}

output "target_group_arn" {
  description = "Target group ARN for EC2"
  value       = aws_lb_target_group.app_tg.arn
}
