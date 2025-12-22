# 3-Tier AWS Architecture with Terraform

A complete Infrastructure as Code (IaC) implementation of a highly available, scalable 3-tier web application architecture on AWS using Terraform modules.

📚 **[View Full Terraform Documentation](DOCS.md)** - Detailed module documentation with all inputs, outputs, and resources.

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Architecture Diagram](#architecture-diagram)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Documentation](#documentation)
- [Module Documentation](#module-documentation)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Testing](#testing)
- [Screenshots](#screenshots)
- [Cost Estimation](#cost-estimation)
- [Cleanup](#cleanup)
- [Troubleshooting](#troubleshooting)

## 🏗️ Architecture Overview

This project implements a production-ready 3-tier architecture consisting of:

### **Tier 1: Presentation Layer (Web Tier)**
- **Application Load Balancer (ALB)** in public subnets across 2 availability zones
- Handles incoming HTTP/HTTPS traffic from the internet
- Distributes traffic to application servers
- Provides SSL termination (optional)

### **Tier 2: Application Layer (App Tier)**
- **Auto Scaling Group (ASG)** with EC2 instances in private subnets
- Runs the web application (Apache/Nginx)
- Scales automatically based on CPU utilization
- Protected by NAT Gateway for outbound internet access
- No direct internet exposure

### **Tier 3: Data Layer (Database Tier)**
- **RDS MySQL/PostgreSQL** in private database subnets
- Isolated from internet access
- Multi-AZ deployment option for high availability
- Automated backups and maintenance windows


### 🎨 Architecture Diagram

```
                         Internet
                            │
                            ▼
                    ┌───────────────┐
                    │  Route 53 DNS │ (Optional)
                    └───────┬───────┘
                            │
                            ▼
                ┌───────────────────────┐
                │  Application Load     │
                │     Balancer (ALB)    │
                │   (Public Subnets)    │
                └───────────┬───────────┘
                            │
        ┌───────────────────┴───────────────────┐
        │                                       │
   ┌────▼────┐                            ┌────▼────┐
   │   AZ-A  │                            │   AZ-B  │
   │ Public  │                            │ Public  │
   │ Subnet  │                            │ Subnet  │
   └─────────┘                            └─────────┘
        │                                       │
        │         NAT Gateway (AZ-A)            │
        │                 │                     │
   ┌────▼────┐            │               ┌────▼────┐
   │   AZ-A  │            │               │   AZ-B  │
   │ Private │◄───────────┘               │ Private │
   │  App    │                            │  App    │
   │ Subnet  │                            │ Subnet  │
   └────┬────┘                            └────┬────┘
        │                                       │
        │    ┌──────────────────────────┐      │
        └────►  Auto Scaling Group      ◄──────┘
             │  (EC2 Instances)         │
             │  - Apache Web Server     │
             │  - Auto Scaling          │
             └──────────┬───────────────┘
                        │
                        ▼
             ┌──────────────────────────┐
             │   RDS MySQL/PostgreSQL   │
             │   (Private DB Subnets)   │
             │   - Multi-AZ (Optional)  │
             │   - Automated Backups    │
             └──────────────────────────┘
```

---

## 📁 Project Structure

```
3-tier-app/
├── main.tf                      # Root module - orchestrates all modules
├── provider.tf                  # AWS provider configuration
├── variables.tf                 # Root module input variables
├── outputs.tf                   # Root module outputs
├── terraform.tfvars.example     # Example variable values
├── README.md                    # Project documentation
│
└── modules/
    ├── networking/              # VPC, Subnets, Gateways, Route Tables
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── security/                # Security Groups for all tiers
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── alb/                     # Application Load Balancer
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── compute/                 # Auto Scaling Group & Launch Template
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── database/                # RDS Instance & DB Subnet Group
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```


## 📋 Prerequisites

Before you begin, ensure you have the following:

1. **AWS Account** with appropriate permissions
2. **Terraform** installed (version >= 1.0)
   ```bash
   terraform --version
   ```
3. **AWS CLI** configured with credentials
   ```bash
   aws configure
   ```
4. **EC2 Key Pair** (optional, for SSH access)
   ```bash
   aws ec2 create-key-pair --key-name my-key --query 'KeyMaterial' --output text > my-key.pem
   chmod 400 my-key.pem
   ```5. **terraform-docs** (optional, for documentation generation)
   ```bash
   # macOS
   brew install terraform-docs
   
   # Linux
   curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/latest/terraform-docs-latest-$(uname)-amd64.tar.gz
   tar -xzf terraform-docs.tar.gz
   sudo mv terraform-docs /usr/local/bin/
   ```

## 📚 Documentation

This project includes comprehensive auto-generated documentation using terraform-docs:

### Main Documentation
- **[DOCS.md](DOCS.md)** - Complete root module documentation with all inputs, outputs, and resources

### Module Documentation
- **[Networking Module](modules/networking/DOCS.md)** - VPC, subnets, IGW, NAT Gateway, route tables
- **[Security Module](modules/security/DOCS.md)** - Security groups for all tiers
- **[ALB Module](modules/alb/DOCS.md)** - Application Load Balancer and target groups
- **[Compute Module](modules/compute/DOCS.md)** - Auto Scaling Group and launch template
- **[Database Module](modules/database/DOCS.md)** - RDS instance and subnet group

### Generate Documentation
To regenerate documentation after making changes:
```bash
./generate-docs.sh
```

For detailed information about terraform-docs, see [TERRAFORM-DOCS-GUIDE.md](TERRAFORM-DOCS-GUIDE.md).
## 🚀 Quick Start

### 1. Clone the Repository

```bash
cd /home/weirdo/dev/iac/terraform/3-tier-app
```

### 2. Create terraform.tfvars

Copy the example file and customize it:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
# Required
aws_region    = "us-east-1"
project_name  = "my-3tier-app"
environment   = "dev"
owner         = "your-name"

# Optional - adjust as needed
db_password   = "YourSecurePassword123!"
key_name      = "my-ec2-key"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the Plan

```bash
terraform plan
```

### 5. Deploy the Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### 6. Get the Application URL

After deployment completes (10-15 minutes), get the ALB URL:

```bash
terraform output alb_dns_name
```

Access the application at: `http://<alb-dns-name>`

## 📚 Module Documentation

### 1. Networking Module

**Purpose:** Creates VPC, subnets, gateways, and routing.

**Resources Created:**
- 1 VPC
- 2 Public Subnets (for ALB)
- 2 Private App Subnets (for EC2)
- 2 Private DB Subnets (for RDS)
- 1 Internet Gateway
- 1 NAT Gateway (with Elastic IP)
- Route Tables and Associations

**Key Variables:**
- `vpc_cidr`: VPC CIDR block (default: 10.0.0.0/16)
- `availability_zones`: List of AZs (default: us-east-1a, us-east-1b)
- `enable_nat_gateway`: Enable NAT Gateway (default: true)

**Outputs:**
- `vpc_id`: VPC identifier
- `public_subnet_ids`: List of public subnet IDs
- `private_app_subnet_ids`: List of app subnet IDs
- `private_db_subnet_ids`: List of DB subnet IDs

### 2. Security Module

**Purpose:** Creates security groups for each tier with appropriate ingress/egress rules.

**Resources Created:**
- ALB Security Group (HTTP/HTTPS from internet)
- App Security Group (HTTP from ALB, SSH from bastion)
- DB Security Group (MySQL/PostgreSQL from app tier)
- Bastion Security Group (optional)

**Key Variables:**
- `alb_ingress_cidr_blocks`: Allowed IPs for ALB (default: 0.0.0.0/0)
- `db_port`: Database port (default: 3306 for MySQL)
- `enable_bastion_access`: Enable bastion host (default: false)

**Outputs:**
- `alb_security_group_id`
- `app_security_group_id`
- `db_security_group_id`

### 3. ALB Module

**Purpose:** Creates Application Load Balancer with target group and listeners.

**Resources Created:**
- Application Load Balancer
- Target Group with health checks
- HTTP Listener (port 80)
- HTTPS Listener (optional)

**Key Variables:**
- `target_group_port`: Port for targets (default: 80)
- `health_check_path`: Health check endpoint (default: /)
- `enable_https`: Enable HTTPS listener (default: false)

**Outputs:**
- `alb_dns_name`: ALB public DNS name
- `target_group_arn`: Target group ARN for ASG

### 4. Compute Module

**Purpose:** Creates Auto Scaling Group with Launch Template.

**Resources Created:**
- Launch Template (with latest Amazon Linux 2 AMI)
- Auto Scaling Group
- Scaling Policies (scale up/down)
- CloudWatch Alarms (CPU monitoring)

**Key Variables:**
- `instance_type`: EC2 instance type (default: t2.micro)
- `min_size`: Minimum instances (default: 1)
- `max_size`: Maximum instances (default: 4)
- `desired_capacity`: Desired instances (default: 2)

**Outputs:**
- `asg_name`: Auto Scaling Group name
- `launch_template_id`: Launch Template ID
- `ami_id`: AMI ID used

### 5. Database Module

**Purpose:** Creates RDS instance with DB subnet group.

**Resources Created:**
- DB Subnet Group
- RDS Instance (MySQL or PostgreSQL)

**Key Variables:**
- `engine`: Database engine (default: mysql)
- `engine_version`: Engine version (default: 8.0)
- `instance_class`: RDS instance class (default: db.t3.micro)
- `multi_az`: Enable Multi-AZ (default: false)
- `master_password`: Database password (sensitive)

**Outputs:**
- `db_instance_endpoint`: RDS connection endpoint
- `db_instance_address`: RDS hostname
- `db_instance_port`: Database port

## ⚙️ Configuration

### Variable Files

Create a `terraform.tfvars` file with your custom values:

```hcl
# AWS Configuration
aws_region = "us-east-1"

# Project Details
project_name = "myapp"
environment  = "dev"
owner        = "john-doe"

# Network Configuration
vpc_cidr                 = "10.0.0.0/16"
availability_zones       = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs      = ["10.0.1.0/24", "10.0.2.0/24"]
private_app_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
private_db_subnet_cidrs  = ["10.0.21.0/24", "10.0.22.0/24"]

# Compute Configuration
instance_type        = "t2.micro"
key_name             = "my-key"
asg_min_size         = 1
asg_max_size         = 4
asg_desired_capacity = 2

# Database Configuration
db_engine           = "mysql"
db_engine_version   = "8.0"
db_instance_class   = "db.t3.micro"
db_allocated_storage = 20
db_name             = "appdb"
db_username         = "admin"
db_password         = "YourSecurePassword123!"
db_multi_az         = false
```

### Environment-Specific Configurations

For multiple environments, create separate `.tfvars` files:

```bash
# Development
terraform apply -var-file="environments/dev.tfvars"

# Staging
terraform apply -var-file="environments/staging.tfvars"

# Production
terraform apply -var-file="environments/prod.tfvars"
```

## 🚀 Deployment

### Standard Deployment

```bash
# Initialize
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Plan changes
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan
```

### Deployment with Auto-Approve

```bash
terraform apply -auto-approve
```

### Deployment to Specific Region

```bash
terraform apply -var="aws_region=us-west-2"
```

## 🧪 Testing

### 1. Test ALB Connectivity

```bash
# Get ALB DNS name
ALB_DNS=$(terraform output -raw alb_dns_name)

# Test HTTP access
curl -I http://$ALB_DNS

# Expected: HTTP/1.1 200 OK
```

### 2. Test ICMP (Ping)

```bash
# Ping ALB (if security group allows ICMP)
ping -c 4 $ALB_DNS
```

### 3. Test Application

Open the ALB URL in a browser:
```bash
echo "http://$(terraform output -raw alb_dns_name)"
```

You should see a colorful welcome page showing:
- Instance ID
- Availability Zone

Refresh multiple times to see load balancing in action!

### 4. Test Auto Scaling

```bash
# Get ASG name
ASG_NAME=$(terraform output -raw asg_name)

# Check current capacity
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names $ASG_NAME \
  --query 'AutoScalingGroups[0].Instances[*].[InstanceId,HealthStatus,LifecycleState]' \
  --output table
```

### 5. Test Database Connectivity

From a bastion host or EC2 instance in the same VPC:

```bash
# MySQL
mysql -h $(terraform output -raw rds_address) -u admin -p

# PostgreSQL
psql -h $(terraform output -raw rds_address) -U admin -d appdb
```

### 6. Verify Security Groups

```bash
# List all security groups
terraform state list | grep aws_security_group

# Show specific security group rules
terraform state show module.security.aws_security_group.app
```

## 📸 Screenshots

### Required Screenshots for Documentation:

1. **VPC and Subnets**
   - Navigate to: VPC Dashboard → Your VPCs
   - Capture: VPC details showing subnets across AZs

2. **Application Load Balancer**
   - Navigate to: EC2 Dashboard → Load Balancers
   - Capture: ALB with status, DNS name, and listeners

3. **Auto Scaling Group**
   - Navigate to: EC2 Dashboard → Auto Scaling Groups
   - Capture: ASG details showing desired/current capacity and instances

4. **Launch Template**
   - Navigate to: EC2 Dashboard → Launch Templates
   - Capture: Template details and version

5. **RDS Instance**
   - Navigate to: RDS Dashboard → Databases
   - Capture: Database details showing endpoint and status

6. **Security Groups**
   - Navigate to: EC2 Dashboard → Security Groups
   - Capture: List of all security groups created

7. **Terraform Apply Output**
   - Capture terminal output of successful `terraform apply`

8. **Web Application**
   - Access ALB DNS name in browser
   - Capture the welcome page

9. **ICMP Test (Ping)**
   - From bastion or local machine
   - Capture successful ping response

## 💰 Cost Estimation

Estimated monthly costs in US-East-1 (as of 2024):

| Resource | Quantity | Estimated Cost |
|----------|----------|----------------|
| VPC | 1 | $0 (free) |
| NAT Gateway | 1 | ~$32.40 |
| Application Load Balancer | 1 | ~$16.20 |
| EC2 t2.micro (ASG) | 2 | ~$16.80 |
| RDS db.t3.micro | 1 | ~$15.33 |
| EBS Storage | ~40 GB | ~$4.00 |
| Data Transfer | Variable | ~$10.00 |
| **Total** | | **~$95-100/month** |

**Cost Optimization Tips:**
- Use Spot Instances for non-production (up to 90% savings)
- Stop RDS instances overnight in dev environments
- Use single NAT Gateway instead of per-AZ
- Enable RDS storage autoscaling
- Use Reserved Instances for production (up to 72% savings)

## 🧹 Cleanup

### Destroy All Resources

```bash
# Preview what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy
```

### Destroy Specific Resources

```bash
# Destroy only compute resources
terraform destroy -target=module.compute

# Destroy only database
terraform destroy -target=module.database
```

### Important Notes:
- RDS deletion can take 5-10 minutes
- Final snapshots are created by default (can be disabled)
- NAT Gateway EIP may need manual cleanup
- Check AWS Console to verify all resources are deleted

## 🔧 Troubleshooting

### Issue: Terraform Init Fails

```bash
# Clear cache
rm -rf .terraform .terraform.lock.hcl

# Reinitialize
terraform init
```

### Issue: ASG Instances Not Healthy

```bash
# Check instance logs
aws ec2 get-console-output --instance-id <instance-id>

# Check target group health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn)
```

### Issue: Cannot Connect to ALB

1. Check security group rules:
   ```bash
   aws ec2 describe-security-groups \
     --group-ids $(terraform output -raw alb_security_group_id)
   ```

2. Verify ALB is active:
   ```bash
   aws elbv2 describe-load-balancers \
     --load-balancer-arns $(terraform output -raw alb_arn)
   ```

### Issue: RDS Connection Timeout

1. Verify security group allows connections
2. Check if instances are in correct subnets
3. Verify RDS is available:
   ```bash
   aws rds describe-db-instances \
     --db-instance-identifier $(terraform output -raw database_name)
   ```

### Issue: High AWS Costs

1. Check running instances:
   ```bash
   aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"
   ```

2. Check NAT Gateway:
   ```bash
   aws ec2 describe-nat-gateways --filter "Name=state,Values=available"
   ```

3. Stop/terminate unused resources immediately

### Issue: State Lock

```bash
# Force unlock (use carefully!)
terraform force-unlock <lock-id>
```

## 📝 Additional Resources

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [Auto Scaling Best Practices](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-best-practices.html)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

**[Abraham Ayamigah](https://github.com/Ayamigah16)**

- Project: 3-Tier AWS Architecture
- Environment: ${var.environment}
- Managed by: Terraform

---
