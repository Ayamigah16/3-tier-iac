# 3-Tier AWS Architecture - Terraform Documentation

## Overview

This project implements a complete **3-Tier AWS Architecture** using Terraform modules with the following layers:

1. **Presentation Layer (Tier 1)**: Public subnets with Application Load Balancer
2. **Application Layer (Tier 2)**: Private subnets with Auto Scaling Group
3. **Data Layer (Tier 3)**: Private DB subnets with RDS MySQL/PostgreSQL

## Architecture Diagram

```
                         ┌─────────────────────────────┐
                         │     Application Load        │
                         │        Balancer (ALB)       │
                         └──────────────┬──────────────┘
                                        │
               ┌────────────────────────────────────────────────┐
               │                                                │
        Public Subnet A                                  Public Subnet B
               │                                                │
               ▼                                                ▼
        ┌─────────────┐                                  ┌─────────────┐
        │  Web/App    │                                  │  Web/App    │
        │   EC2/ASG   │                                  │   EC2/ASG   │
        └─────────────┘                                  └─────────────┘
               ▼                                                ▼
        ┌────────────────────────────────────────────────────────────────┐
        │                        RDS MySQL/PostgreSQL DB                 │
        │                      (Private DB Subnets)                      │
        └────────────────────────────────────────────────────────────────┘
```

## Modules

This project consists of the following Terraform modules:

### 1. [Networking Module](modules/networking/DOCS.md)
Creates VPC, subnets, Internet Gateway, NAT Gateway, and route tables.

### 2. [Security Module](modules/security/DOCS.md)
Manages security groups for ALB, application servers, database, and optional bastion host.

### 3. [ALB Module](modules/alb/DOCS.md)
Configures Application Load Balancer, target groups, listeners, and health checks.

### 4. [Compute Module](modules/compute/DOCS.md)
Manages Auto Scaling Group, launch template, and scaling policies.

### 5. [Database Module](modules/database/DOCS.md)
Provisions RDS instance, DB subnet group, and backup configuration.

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- terraform-docs (for documentation generation)

## Quick Start

1. **Clone the repository**
```bash
git clone <repository-url>
cd 3-tier-app
```

2. **Create terraform.tfvars**
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

3. **Initialize Terraform**
```bash
terraform init
```

4. **Review the plan**
```bash
terraform plan
```

5. **Deploy the infrastructure**
```bash
terraform apply
```

6. **Access the application**
```bash
# Get the ALB DNS name
terraform output alb_dns_name
```

## Usage Example

```hcl
module "three_tier_app" {
  source = "."

  project_name = "my-app"
  environment  = "production"
  owner        = "DevOps Team"
  
  vpc_cidr            = "10.0.0.0/16"
  availability_zones  = ["us-east-1a", "us-east-1b"]
  
  instance_type       = "t3.small"
  asg_min_size        = 2
  asg_max_size        = 6
  asg_desired_capacity = 3
  
  db_instance_class   = "db.t3.small"
  db_multi_az         = true
}
```

## Resource Tagging

All resources are tagged with:
- `Environment`: dev/staging/prod
- `Project`: Project name
- `Owner`: Team/person responsible
- `Terraform`: "true"

## Security Features

- ✅ Private subnets for application and database tiers
- ✅ Security groups with least-privilege access
- ✅ Encrypted RDS storage
- ✅ NAT Gateway for outbound traffic
- ✅ IMDSv2 required for EC2 metadata
- ✅ HTTPS support (optional)

## High Availability Features

- ✅ Multi-AZ deployment across 2 availability zones
- ✅ Auto Scaling Group with health checks
- ✅ Application Load Balancer with health checks
- ✅ RDS Multi-AZ (optional)
- ✅ Automated backups and snapshots

## Cost Optimization

For development/testing environments:
- Set `enable_nat_gateway = false` (save ~$32/month per NAT Gateway)
- Set `db_multi_az = false` (save ~50% on RDS costs)
- Use smaller instance types: `t2.micro`, `db.t3.micro`
- Reduce `asg_desired_capacity` to 1

## Terraform Documentation

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

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Note**: RDS instances create a final snapshot by default. To skip:
```bash
terraform destroy -var="skip_final_snapshot=true"
```

## Support

For issues or questions, please open an issue in the repository.

## License

MIT License - See LICENSE file for details
