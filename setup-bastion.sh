#!/bin/bash

# Bastion Host Deployment Guide
# This script helps you set up SSH keys and connect to EC2 instances via bastion

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Bastion Host Deployment Guide                      ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if we're in the right directory
if [ ! -f "main.tf" ]; then
    echo -e "${RED}Error: Please run this script from the 3-tier-iac directory${NC}"
    exit 1
fi

echo -e "${YELLOW}Step 1: Create SSH Key Pair${NC}"
echo "----------------------------------------"
read -p "Enter key pair name (default: 3tier-iac-key): " KEY_NAME
KEY_NAME=${KEY_NAME:-3tier-iac-key}

if [ ! -f "$HOME/.ssh/${KEY_NAME}.pem" ]; then
    echo "Creating SSH key pair in AWS..."
    aws ec2 create-key-pair \
        --key-name "${KEY_NAME}" \
        --query 'KeyMaterial' \
        --output text > "$HOME/.ssh/${KEY_NAME}.pem"
    
    chmod 400 "$HOME/.ssh/${KEY_NAME}.pem"
    echo -e "${GREEN}✓ Key pair created: $HOME/.ssh/${KEY_NAME}.pem${NC}"
else
    echo -e "${GREEN}✓ Key pair already exists: $HOME/.ssh/${KEY_NAME}.pem${NC}"
fi

echo ""
echo -e "${YELLOW}Step 2: Get Your IP Address${NC}"
echo "----------------------------------------"
MY_IP=$(curl -s ifconfig.me)
echo -e "Your public IP: ${GREEN}${MY_IP}${NC}"
echo ""

echo -e "${YELLOW}Step 3: Create terraform.tfvars${NC}"
echo "----------------------------------------"
if [ -f "terraform.tfvars" ]; then
    echo -e "${YELLOW}terraform.tfvars already exists. Backup created.${NC}"
    cp terraform.tfvars terraform.tfvars.backup
fi

cat > terraform.tfvars << EOF
# AWS Region
aws_region = "eu-west-1"

# Project Configuration
project_name = "3tier-iac"
environment  = "dev"
owner        = "YourName"

# Network Configuration
vpc_cidr                 = "10.0.0.0/16"
availability_zones       = ["eu-west-1a", "eu-west-1b"]
public_subnet_cidrs      = ["10.0.1.0/24", "10.0.2.0/24"]
private_app_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
private_db_subnet_cidrs  = ["10.0.21.0/24", "10.0.22.0/24"]
enable_nat_gateway       = true

# Security Configuration
allowed_cidr_blocks = ["0.0.0.0/0"]
enable_bastion      = true

# Bastion Configuration
key_name              = "${KEY_NAME}"
bastion_instance_type = "t3.micro"
bastion_allowed_cidrs = ["${MY_IP}/32"]

# Compute Configuration
instance_type        = "t3.micro"
asg_min_size         = 1
asg_max_size         = 4
asg_desired_capacity = 2

# Database Configuration
db_engine            = "mysql"
db_engine_version    = "8.0"
db_instance_class    = "db.t3.micro"
db_allocated_storage = 20
db_name              = "appdb"
db_username          = "admin"
db_multi_az          = false
EOF

echo -e "${GREEN}✓ terraform.tfvars created${NC}"
echo ""

echo -e "${YELLOW}Step 4: Deploy Infrastructure${NC}"
echo "----------------------------------------"
read -p "Do you want to run terraform init and apply now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    terraform init
    terraform plan -out=tfplan
    
    echo ""
    read -p "Review the plan above. Apply? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform apply tfplan
        rm tfplan
        
        echo ""
        echo -e "${GREEN}✓ Infrastructure deployed!${NC}"
        echo ""
        
        # Get outputs
        BASTION_IP=$(terraform output -raw bastion_public_ip 2>/dev/null || echo "")
        
        if [ -n "$BASTION_IP" ]; then
            echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${BLUE}║                Connection Instructions                       ║${NC}"
            echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
            echo ""
            echo -e "${GREEN}Bastion IP:${NC} ${BASTION_IP}"
            echo ""
            echo -e "${YELLOW}Connect to bastion:${NC}"
            echo "  ssh -i ~/.ssh/${KEY_NAME}.pem ec2-user@${BASTION_IP}"
            echo ""
            echo -e "${YELLOW}Get private instance IPs:${NC}"
            echo "  aws ec2 describe-instances \\"
            echo "    --filters \"Name=tag:Name,Values=3tier-iac-asg-instance\" \"Name=instance-state-name,Values=running\" \\"
            echo "    --query \"Reservations[*].Instances[*].[InstanceId,PrivateIpAddress]\" \\"
            echo "    --output table"
            echo ""
            echo -e "${YELLOW}Connect to private instance from bastion:${NC}"
            echo "  ssh ec2-user@<private-ip>"
            echo ""
            echo -e "${YELLOW}Forward SSH agent (recommended):${NC}"
            echo "  ssh-add ~/.ssh/${KEY_NAME}.pem"
            echo "  ssh -A ec2-user@${BASTION_IP}"
            echo ""
        fi
    fi
fi

echo ""
echo -e "${GREEN}Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Connect to bastion host"
echo "  2. From bastion, SSH to private EC2 instances"
echo "  3. Deploy your application"
echo ""
