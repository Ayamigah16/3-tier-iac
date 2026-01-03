locals {
  # Database port based on engine
  db_port = var.db_engine == "mysql" ? 3306 : 5432

  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
  }

  # User data script for web servers
  user_data = <<-EOF
              #!/bin/bash
              set -euo pipefail
              
              # Update system
              yum update -y
              
              # Install Docker
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user
              
              # Install AWS CLI v2
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
              unzip -q /tmp/awscliv2.zip -d /tmp
              /tmp/aws/install
              rm -rf /tmp/aws /tmp/awscliv2.zip
              
              # Note: Actual container deployment is done via deploy-to-ec2.sh script
              # This ensures the latest image is pulled after it's built and pushed to ECR
              
              echo "Instance ready for container deployment" > /var/log/user-data-complete.log
              EOF
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  project_name             = var.project_name
  vpc_cidr                 = var.vpc_cidr
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  availability_zones       = var.availability_zones
  enable_nat_gateway       = var.enable_nat_gateway

  tags = local.common_tags
}

# Security Module
module "security" {
  source = "./modules/security"

  project_name                = var.project_name
  vpc_id                      = module.networking.vpc_id
  vpc_cidr                    = module.networking.vpc_cidr
  alb_ingress_cidr_blocks     = var.allowed_cidr_blocks
  db_port                     = local.db_port
  enable_bastion_access       = var.enable_bastion
  bastion_ingress_cidr_blocks = var.bastion_allowed_cidrs
  bastion_cidr_blocks         = []

  tags = local.common_tags
}

# Bastion Module
module "bastion" {
  count  = var.enable_bastion ? 1 : 0
  source = "./modules/bastion"

  project_name              = var.project_name
  key_name                  = var.key_name
  public_subnet_id          = module.networking.public_subnet_ids[0]
  bastion_security_group_id = module.security.bastion_security_group_id
  instance_type             = var.bastion_instance_type
  enable_eip                = true

  tags = local.common_tags
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"

  project_name                  = var.project_name
  repository_name               = "noteservice"
  enable_image_scanning         = true
  enable_lifecycle_policy       = true
  max_image_count               = 10
  untagged_image_retention_days = 7

  tags = local.common_tags
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  project_name  = var.project_name
  db_secret_arn = module.database.db_secret_arn

  tags = local.common_tags
}

# ALB Module
module "alb" {
  source = "./modules/alb"

  project_name          = var.project_name
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  
  # NoteService runs on port 3000
  target_group_port     = 3000
  health_check_path     = "/api/health"

  tags = local.common_tags
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  project_name              = var.project_name
  instance_type             = var.instance_type
  key_name                  = var.key_name
  app_security_group_id     = module.security.app_security_group_id
  private_subnet_ids        = module.networking.private_app_subnet_ids
  target_group_arns         = [module.alb.target_group_arn]
  user_data                 = local.user_data
  iam_instance_profile_name = module.iam.ec2_instance_profile_name

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  tags = local.common_tags
}

# Database Module
module "database" {
  source = "./modules/database"

  project_name          = var.project_name
  private_db_subnet_ids = module.networking.private_db_subnet_ids
  db_security_group_id  = module.security.db_security_group_id

  engine            = var.db_engine
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  database_name     = var.db_name
  db_username       = var.db_username
  database_port     = local.db_port
  multi_az          = var.db_multi_az

  tags = local.common_tags
}
