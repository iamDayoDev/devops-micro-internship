output "public_alb_dns" {
  description = "DNS name of the public Application Load Balancer"
  value       = aws_lb.public_alb.dns_name
}

output "internal_alb_dns" {
  description = "DNS name of the private Application Load Balancer"
  value       = aws_lb.internal_alb.dns_name
}