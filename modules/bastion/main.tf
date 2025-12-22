# Data source for latest Amazon Linux 2 AMI
data "aws_ssm_parameter" "bastion_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Bastion Host EC2 Instance
resource "aws_instance" "bastion" {
  ami                         = data.aws_ssm_parameter.bastion_ami.value
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.bastion_security_group_id]
  associate_public_ip_address = true

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    project_name = var.project_name
  }))

  monitoring = var.enable_monitoring

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = var.require_imdsv2 ? "required" : "optional"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-bastion"
      Role = "Bastion"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP for Bastion (optional but recommended)
resource "aws_eip" "bastion" {
  count    = var.enable_eip ? 1 : 0
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-bastion-eip"
    }
  )

  depends_on = [aws_instance.bastion]
}
