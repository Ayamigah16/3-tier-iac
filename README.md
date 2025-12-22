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

## 🎨 Architecture Diagram

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

## ✨ Features

### Networking
- ✅ VPC with custom CIDR block
- ✅ 6 subnets across 2 availability zones (2 public, 2 private app, 2 private DB)
- ✅ Internet Gateway for public subnets
- ✅ NAT Gateway for private subnet internet access
- ✅ Custom route tables for each tier
- ✅ DNS support enabled

### Security
- ✅ Layered security groups for each tier
- ✅ ALB security group (HTTP/HTTPS from internet)
- ✅ Application security group (traffic from ALB only)
- ✅ Database security group (traffic from app tier only)
- ✅ ICMP enabled for ping testing
- ✅ Optional bastion host support

### Load Balancing
- ✅ Application Load Balancer (internet-facing)
- ✅ HTTP/HTTPS listeners
- ✅ Health checks for targets
- ✅ Cross-zone load balancing

### Compute
- ✅ Launch Template with latest Amazon Linux 2 AMI
- ✅ Auto Scaling Group with dynamic scaling
- ✅ CPU-based scaling policies
- ✅ CloudWatch alarms for monitoring
- ✅ User data script for web server setup
- ✅ IMDSv2 enforced
- ✅ EBS encryption enabled

### Database
- ✅ RDS MySQL or PostgreSQL
- ✅ Private subnet deployment
- ✅ Automated backups
- ✅ Multi-AZ option for HA
- ✅ Storage encryption
- ✅ CloudWatch logs export
- ✅ Performance Insights (optional)

### Best Practices
- ✅ No hardcoded values
- ✅ All resources parameterized
- ✅ Consistent tagging strategy
- ✅ Modular and reusable code
- ✅ Latest AMI from SSM Parameter Store
- ✅ Deletion protection options
- ✅ Sensitive data handling

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

**${var.owner}**

- Project: 3-Tier AWS Architecture
- Environment: ${var.environment}
- Managed by: Terraform

---

**⚠️ Important Security Notes:**

1. Change default database password immediately
2. Use AWS Secrets Manager for sensitive data
3. Implement least privilege IAM policies
4. Enable AWS CloudTrail for auditing
5. Use private S3 bucket for Terraform state
6. Rotate credentials regularly
7. Enable AWS Config for compliance monitoring

**🎯 Next Steps:**

1. Set up CI/CD pipeline
2. Implement monitoring with CloudWatch
3. Configure CloudWatch Alarms
4. Set up AWS Backup for RDS
5. Implement AWS WAF for ALB
6. Configure Route53 for custom domain
7. Add SSL/TLS certificate to ALB
8. Implement application-level logging

---

Made with ❤️ using Terraform

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | ./modules/alb | n/a |
| <a name="module_compute"></a> [compute](#module\_compute) | ./modules/compute | n/a |
| <a name="module_database"></a> [database](#module\_database) | ./modules/database | n/a |
| <a name="module_networking"></a> [networking](#module\_networking) | ./modules/networking | n/a |
| <a name="module_security"></a> [security](#module\_security) | ./modules/security | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | CIDR blocks allowed to access ALB | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_asg_desired_capacity"></a> [asg\_desired\_capacity](#input\_asg\_desired\_capacity) | Desired number of instances in ASG | `number` | `2` | no |
| <a name="input_asg_max_size"></a> [asg\_max\_size](#input\_asg\_max\_size) | Maximum number of instances in ASG | `number` | `4` | no |
| <a name="input_asg_min_size"></a> [asg\_min\_size](#input\_asg\_min\_size) | Minimum number of instances in ASG | `number` | `1` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones | `list(string)` | <pre>[<br/>  "eu-west-1a",<br/>  "eu-west-1b"<br/>]</pre> | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to deploy resources | `string` | `"eu-west-1"` | no |
| <a name="input_db_allocated_storage"></a> [db\_allocated\_storage](#input\_db\_allocated\_storage) | Allocated storage in GB | `number` | `20` | no |
| <a name="input_db_engine"></a> [db\_engine](#input\_db\_engine) | Database engine (mysql or postgres) | `string` | `"mysql"` | no |
| <a name="input_db_engine_version"></a> [db\_engine\_version](#input\_db\_engine\_version) | Database engine version | `string` | `"8.0"` | no |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | RDS instance class | `string` | `"db.t3.micro"` | no |
| <a name="input_db_multi_az"></a> [db\_multi\_az](#input\_db\_multi\_az) | Enable Multi-AZ deployment for RDS | `bool` | `false` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Name of the default database | `string` | `"appdb"` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Master username for the database | `string` | `"admin"` | no |
| <a name="input_enable_bastion"></a> [enable\_bastion](#input\_enable\_bastion) | Enable bastion host for SSH access | `bool` | `false` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Enable NAT Gateway for private subnets | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type for application servers | `string` | `"t3.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | EC2 key pair name for SSH access | `string` | `""` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Project owner/team name | `string` | `"Abraham Ayamigah"` | no |
| <a name="input_private_app_subnet_cidrs"></a> [private\_app\_subnet\_cidrs](#input\_private\_app\_subnet\_cidrs) | CIDR blocks for private application subnets | `list(string)` | <pre>[<br/>  "10.0.11.0/24",<br/>  "10.0.12.0/24"<br/>]</pre> | no |
| <a name="input_private_db_subnet_cidrs"></a> [private\_db\_subnet\_cidrs](#input\_private\_db\_subnet\_cidrs) | CIDR blocks for private database subnets | `list(string)` | <pre>[<br/>  "10.0.21.0/24",<br/>  "10.0.22.0/24"<br/>]</pre> | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name used for resource naming | `string` | `"3tier-iac"` | no |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | CIDR blocks for public subnets | `list(string)` | <pre>[<br/>  "10.0.1.0/24",<br/>  "10.0.2.0/24"<br/>]</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for VPC | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | ALB ARN |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | ALB DNS name - Use this URL to access the application |
| <a name="output_alb_security_group_id"></a> [alb\_security\_group\_id](#output\_alb\_security\_group\_id) | ALB Security Group ID |
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | AMI ID used for EC2 instances |
| <a name="output_app_security_group_id"></a> [app\_security\_group\_id](#output\_app\_security\_group\_id) | Application Security Group ID |
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | Auto Scaling Group name |
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | Database name |
| <a name="output_db_secret_arn"></a> [db\_secret\_arn](#output\_db\_secret\_arn) | ARN of AWS Secrets Manager secret containing database credentials |
| <a name="output_db_secret_name"></a> [db\_secret\_name](#output\_db\_secret\_name) | Name of AWS Secrets Manager secret containing database credentials |
| <a name="output_db_security_group_id"></a> [db\_security\_group\_id](#output\_db\_security\_group\_id) | Database Security Group ID |
| <a name="output_db_username"></a> [db\_username](#output\_db\_username) | Database master username |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | Launch Template ID |
| <a name="output_private_app_subnet_ids"></a> [private\_app\_subnet\_ids](#output\_private\_app\_subnet\_ids) | Private application subnet IDs |
| <a name="output_private_db_subnet_ids"></a> [private\_db\_subnet\_ids](#output\_private\_db\_subnet\_ids) | Private database subnet IDs |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | Public subnet IDs |
| <a name="output_rds_address"></a> [rds\_address](#output\_rds\_address) | RDS address |
| <a name="output_rds_endpoint"></a> [rds\_endpoint](#output\_rds\_endpoint) | RDS endpoint |
| <a name="output_rds_port"></a> [rds\_port](#output\_rds\_port) | RDS port |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | Target Group ARN |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | VPC CIDR block |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
<!-- END_TF_DOCS -->