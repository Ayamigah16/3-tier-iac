output "bastion_instance_id" {
  description = "Bastion host instance ID"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Bastion host public IP address"
  value       = aws_instance.bastion.public_ip
}

output "bastion_eip" {
  description = "Bastion host Elastic IP (if enabled)"
  value       = var.enable_eip ? aws_eip.bastion[0].public_ip : null
}

output "bastion_private_ip" {
  description = "Bastion host private IP address"
  value       = aws_instance.bastion.private_ip
}

output "ssh_command" {
  description = "SSH command to connect to bastion"
  value       = "ssh -i ${var.key_name}.pem ec2-user@${var.enable_eip ? aws_eip.bastion[0].public_ip : aws_instance.bastion.public_ip}"
}

output "ami_id" {
  description = "AMI ID used for bastion"
  value       = data.aws_ssm_parameter.bastion_ami.value
  sensitive   = true
}
