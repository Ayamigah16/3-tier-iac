<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_ingress_cidr_blocks"></a> [alb\_ingress\_cidr\_blocks](#input\_alb\_ingress\_cidr\_blocks) | CIDR blocks allowed to access ALB | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_bastion_cidr_blocks"></a> [bastion\_cidr\_blocks](#input\_bastion\_cidr\_blocks) | CIDR blocks for bastion hosts (to allow SSH to app servers) | `list(string)` | `[]` | no |
| <a name="input_bastion_ingress_cidr_blocks"></a> [bastion\_ingress\_cidr\_blocks](#input\_bastion\_ingress\_cidr\_blocks) | CIDR blocks allowed to SSH into bastion | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_db_port"></a> [db\_port](#input\_db\_port) | Database port (3306 for MySQL, 5432 for PostgreSQL) | `number` | `3306` | no |
| <a name="input_enable_bastion_access"></a> [enable\_bastion\_access](#input\_enable\_bastion\_access) | Enable bastion host security group | `bool` | `false` | no |
| <a name="input_enable_https"></a> [enable\_https](#input\_enable\_https) | Enable HTTPS rules | `bool` | `false` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name for resource naming | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags for all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR block for internal rules | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where security groups will be created | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_security_group_id"></a> [alb\_security\_group\_id](#output\_alb\_security\_group\_id) | ALB Security Group ID |
| <a name="output_app_security_group_id"></a> [app\_security\_group\_id](#output\_app\_security\_group\_id) | Application Security Group ID |
| <a name="output_bastion_security_group_id"></a> [bastion\_security\_group\_id](#output\_bastion\_security\_group\_id) | Bastion Security Group ID (if enabled) |
| <a name="output_db_security_group_id"></a> [db\_security\_group\_id](#output\_db\_security\_group\_id) | Database Security Group ID |
<!-- END_TF_DOCS -->