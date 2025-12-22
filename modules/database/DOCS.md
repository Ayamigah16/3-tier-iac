<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_secretsmanager_secret.db_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.db_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [random_password.master](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Allocated storage in GB | `number` | `20` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Apply changes immediately | `bool` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Enable automatic minor version upgrades | `bool` | `true` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Availability zone for single-AZ deployment | `string` | `null` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Backup retention period in days | `number` | `7` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | Preferred backup window | `string` | `"03:00-04:00"` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name of the default database | `string` | `"appdb"` | no |
| <a name="input_database_port"></a> [database\_port](#input\_database\_port) | Database port | `number` | `3306` | no |
| <a name="input_db_security_group_id"></a> [db\_security\_group\_id](#input\_db\_security\_group\_id) | Security group ID for RDS | `string` | n/a | yes |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Database master username | `string` | `"admin"` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Enable deletion protection | `bool` | `false` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | List of log types to export to CloudWatch | `list(string)` | <pre>[<br/>  "error",<br/>  "general",<br/>  "slowquery"<br/>]</pre> | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Database engine (mysql, postgres, etc.) | `string` | `"mysql"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Database engine version | `string` | `"8.0"` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | RDS instance class | `string` | `"db.t3.micro"` | no |
| <a name="input_iops"></a> [iops](#input\_iops) | IOPS for io1/io2 storage type | `number` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Preferred maintenance window | `string` | `"sun:04:00-sun:05:00"` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | Maximum allocated storage for autoscaling in GB | `number` | `100` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Enable Multi-AZ deployment | `bool` | `false` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Enable Performance Insights | `bool` | `false` | no |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | Performance Insights retention period in days | `number` | `7` | no |
| <a name="input_private_db_subnet_ids"></a> [private\_db\_subnet\_ids](#input\_private\_db\_subnet\_ids) | List of private subnet IDs for RDS | `list(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name for resource naming | `string` | n/a | yes |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Make database publicly accessible | `bool` | `false` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Skip final snapshot when deleting | `bool` | `true` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Enable storage encryption | `bool` | `true` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Storage type (gp2, gp3, io1, io2) | `string` | `"gp3"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags for all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_instance_address"></a> [db\_instance\_address](#output\_db\_instance\_address) | RDS instance address |
| <a name="output_db_instance_arn"></a> [db\_instance\_arn](#output\_db\_instance\_arn) | RDS instance ARN |
| <a name="output_db_instance_endpoint"></a> [db\_instance\_endpoint](#output\_db\_instance\_endpoint) | RDS instance endpoint |
| <a name="output_db_instance_id"></a> [db\_instance\_id](#output\_db\_instance\_id) | RDS instance ID |
| <a name="output_db_instance_name"></a> [db\_instance\_name](#output\_db\_instance\_name) | Database name |
| <a name="output_db_instance_port"></a> [db\_instance\_port](#output\_db\_instance\_port) | RDS instance port |
| <a name="output_db_secret_arn"></a> [db\_secret\_arn](#output\_db\_secret\_arn) | ARN of the secret containing database credentials |
| <a name="output_db_secret_name"></a> [db\_secret\_name](#output\_db\_secret\_name) | Name of the secret containing database credentials |
| <a name="output_db_subnet_group_arn"></a> [db\_subnet\_group\_arn](#output\_db\_subnet\_group\_arn) | DB subnet group ARN |
| <a name="output_db_subnet_group_name"></a> [db\_subnet\_group\_name](#output\_db\_subnet\_group\_name) | DB subnet group name |
| <a name="output_db_username"></a> [db\_username](#output\_db\_username) | Database master username |
<!-- END_TF_DOCS -->