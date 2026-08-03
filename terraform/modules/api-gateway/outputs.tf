output "alb_arn" {
  value       = aws_lb.main.arn
  description = "ARN of the Application Load Balancer"
}

output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "DNS name of the Application Load Balancer"
}

output "alb_zone_id" {
  value       = aws_lb.main.zone_id
  description = "Canonical hosted zone ID of the Application Load Balancer"
}

output "target_group_arn" {
  value       = aws_lb_target_group.orchestrator.arn
  description = "ARN of the orchestrator target group"
}

output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "Security group ID of the Application Load Balancer"
}

output "web_acl_arn" {
  value       = aws_wafv2_web_acl.main.arn
  description = "ARN of the associated WAF WebACL"
}
