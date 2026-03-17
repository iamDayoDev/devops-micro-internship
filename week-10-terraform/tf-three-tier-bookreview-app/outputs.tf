output "webserver_pub_ip" {
  value = module.ec2.web_server_pub_ip
}

output "appserver_prvt_ip" {
  value = module.ec2.app_server_prvt_ip
}

output "db_endpoint" {
  value = module.database.db_endpoint
}

output "public_alb_dns" {
  description = "DNS name of the public Application Load Balancer"
  value       = module.alb.public_alb_dns
}

output "private_alb_dns" {
  description = "DNS name of the private Application Load Balancer"
  value       = module.alb.private_alb_dns
}