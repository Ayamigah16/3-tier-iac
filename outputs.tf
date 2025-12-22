# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.networking.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Private application subnet IDs"
  value       = module.networking.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "Private database subnet IDs"
  value       = module.networking.private_db_subnet_ids
}

# Security Group Outputs
output "alb_security_group_id" {
  description = "ALB Security Group ID"
  value       = module.security.alb_security_group_id
}

output "app_security_group_id" {
  description = "Application Security Group ID"
  value       = module.security.app_security_group_id
}

output "db_security_group_id" {
  description = "Database Security Group ID"
  value       = module.security.db_security_group_id
}

# ALB Outputs
output "alb_dns_name" {
  description = "ALB DNS name - Use this URL to access the application"
  value       = "http://${module.alb.alb_dns_name}"
}

output "alb_arn" {
  description = "ALB ARN"
  value       = module.alb.alb_arn
}

output "target_group_arn" {
  description = "Target Group ARN"
  value       = module.alb.target_group_arn
}

# Compute Outputs
output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.compute.asg_name
}

output "launch_template_id" {
  description = "Launch Template ID"
  value       = module.compute.launch_template_id
}

output "ami_id" {
  description = "AMI ID used for EC2 instances"
  value       = module.compute.ami_id
  sensitive   = true
}

# Database Outputs
output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.database.db_instance_endpoint
}

output "rds_address" {
  description = "RDS address"
  value       = module.database.db_instance_address
}

output "rds_port" {
  description = "RDS port"
  value       = module.database.db_instance_port
}

output "database_name" {
  description = "Database name"
  value       = module.database.db_instance_name
  sensitive   = true
}

output "db_secret_arn" {
  description = "ARN of AWS Secrets Manager secret containing database credentials"
  value       = module.database.db_secret_arn
}

output "db_secret_name" {
  description = "Name of AWS Secrets Manager secret containing database credentials"
  value       = module.database.db_secret_name
}

output "db_username" {
  description = "Database master username"
  value       = module.database.db_username
  sensitive   = true
}
