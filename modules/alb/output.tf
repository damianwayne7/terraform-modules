output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.verdethos_alb.arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.verdethos_alb.dns_name
}

output "alb_zone_id" {
  description = "ALB zone id"
  value       = aws_lb.verdethos_alb.zone_id
}

output "target_group_arn" {
  description = "Target group ARN"
  value       = aws_lb_target_group.verdethos_tg.arn
}

output "listener_http_arn" {
  description = "HTTP listener ARN"
  value       = aws_lb_listener.verdethos_http_listener.arn
}

output "listener_https_arn" {
  description = "HTTPS listener ARN (empty if disabled)"
  value       = var.enable_https ? aws_lb_listener.verdethos_https_listener[0].arn : ""
}
