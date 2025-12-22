output "alb_security_group_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Application Security Group ID"
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "Database Security Group ID"
  value       = aws_security_group.db.id
}

output "bastion_security_group_id" {
  description = "Bastion Security Group ID (if enabled)"
  value       = var.enable_bastion_access ? aws_security_group.bastion[0].id : null
}
