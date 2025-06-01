output "subnet_ranges" {
  value = local.subnets
}

output "sg_app" {
  value       = aws_security_group.sg_app.id
  description = "Security group for the application instances"
}

output "subnets" {
  value       = module.vpc_app.private_subnets
  description = "List if IDs of the private subnets in the VPC"
}

output "vpc_app_id" {
  value       = module.vpc_app.vpc_id
  description = "ID of the VPC for the feedback application"
}

output "target_group_arn" {
  value       = aws_lb_target_group.target_group.arn
  description = "ARN of the target group for the Network Load Balancer"
}

output "alb_dns_name" {
  value = try(aws_lb.alb[0].dns_name, null)
}