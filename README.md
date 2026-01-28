# 3-Tier AWS Infrastructure with Terraform

A production-ready 3-tier architecture deployed on AWS using Terraform, featuring web, application, and database layers with proper security groups and load balancing.

## Architecture

This project deploys a scalable 3-tier architecture consisting of:

- **Web Tier**: Application Load Balancer (ALB) in public subnets
- **Application Tier**: Auto Scaling Group with EC2 instances in private subnets
- **Database Tier**: RDS MySQL instance in private database subnets

## Features

- **Modular Design**: Organized into reusable Terraform modules
- **High Availability**: Multi-AZ deployment across availability zones
- **Security**: Proper security groups and network isolation
- **Secrets Management**: Database credentials stored in AWS Secrets Manager
- **Auto Scaling**: Automatic scaling based on demand
- **Load Balancing**: Application Load Balancer for traffic distribution

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- AWS CLI configured with appropriate credentials
- An AWS account with necessary permissions

## Quick Start

1. **Clone and navigate to the project**:
   ```bash
   cd 3-tier-iac
   ```

2. **Configure variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Deploy the infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Access your application**:
   ```bash
   terraform output alb_dns
   ```

## Configuration

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `region` | AWS region | `us-east-1` |
| `project` | Project name | `my-app` |
| `environment` | Environment name | `dev` |
| `owner` | Resource owner | `team-name` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `public_subnet_cidrs` | Public subnet CIDRs | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `app_subnet_cidrs` | App subnet CIDRs | `["10.0.11.0/24", "10.0.12.0/24"]` |
| `db_subnet_cidrs` | DB subnet CIDRs | `["10.0.21.0/24", "10.0.22.0/24"]` |
| `db_name` | Database name | `appdb` |
| `db_username` | Database username | `admin` |
| `db_password` | Database password | `SecurePassword123!` |

## Modules

- **networking**: VPC, subnets, route tables, NAT gateway
- **security**: Security groups for web, app, and database tiers
- **alb**: Application Load Balancer and target groups
- **compute**: Auto Scaling Group and EC2 instances
- **database**: RDS MySQL instance
- **secrets**: AWS Secrets Manager for database credentials

## Outputs

- `alb_dns`: Load balancer DNS name for accessing the application
- `asg_name`: Auto Scaling Group name

## Security

- Database credentials are automatically stored in AWS Secrets Manager
- Security groups follow least privilege principle
- Database is isolated in private subnets
- Application instances are in private subnets behind load balancer

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

## License

This project is licensed under the terms specified in the LICENSE file.