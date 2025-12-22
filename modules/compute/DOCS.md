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
| [aws_autoscaling_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_policy.scale_down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_policy.scale_up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_cloudwatch_metric_alarm.high_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.low_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_launch_template.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_ssm_parameter.ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_ssm_parameter"></a> [ami\_ssm\_parameter](#input\_ami\_ssm\_parameter) | SSM parameter name for AMI ID | `string` | `"/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"` | no |
| <a name="input_app_security_group_id"></a> [app\_security\_group\_id](#input\_app\_security\_group\_id) | Security group ID for application instances | `string` | n/a | yes |
| <a name="input_cpu_high_threshold"></a> [cpu\_high\_threshold](#input\_cpu\_high\_threshold) | CPU threshold for scaling up | `number` | `70` | no |
| <a name="input_cpu_low_threshold"></a> [cpu\_low\_threshold](#input\_cpu\_low\_threshold) | CPU threshold for scaling down | `number` | `20` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | Desired number of instances in ASG | `number` | `2` | no |
| <a name="input_enable_autoscaling_policies"></a> [enable\_autoscaling\_policies](#input\_enable\_autoscaling\_policies) | Enable autoscaling policies and alarms | `bool` | `true` | no |
| <a name="input_enable_ebs_encryption"></a> [enable\_ebs\_encryption](#input\_enable\_ebs\_encryption) | Enable EBS encryption | `bool` | `true` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enable detailed monitoring | `bool` | `true` | no |
| <a name="input_enabled_metrics"></a> [enabled\_metrics](#input\_enabled\_metrics) | List of metrics to collect for ASG | `list(string)` | <pre>[<br/>  "GroupMinSize",<br/>  "GroupMaxSize",<br/>  "GroupDesiredCapacity",<br/>  "GroupInServiceInstances",<br/>  "GroupTotalInstances"<br/>]</pre> | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | Health check grace period in seconds | `number` | `300` | no |
| <a name="input_health_check_type"></a> [health\_check\_type](#input\_health\_check\_type) | Health check type (EC2 or ELB) | `string` | `"ELB"` | no |
| <a name="input_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#input\_iam\_instance\_profile\_name) | IAM instance profile name | `string` | `""` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type | `string` | `"t2.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | EC2 key pair name | `string` | `""` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Maximum number of instances in ASG | `number` | `4` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Minimum number of instances in ASG | `number` | `1` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of private subnet IDs for ASG | `list(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name for resource naming | `string` | n/a | yes |
| <a name="input_require_imdsv2"></a> [require\_imdsv2](#input\_require\_imdsv2) | Require IMDSv2 for metadata service | `bool` | `true` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | Root volume size in GB | `number` | `8` | no |
| <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type) | Root volume type | `string` | `"gp3"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags for all resources | `map(string)` | `{}` | no |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | List of target group ARNs to attach to ASG | `list(string)` | `[]` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | User data script for instance initialization | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | AMI ID used for instances |
| <a name="output_asg_arn"></a> [asg\_arn](#output\_asg\_arn) | Auto Scaling Group ARN |
| <a name="output_asg_id"></a> [asg\_id](#output\_asg\_id) | Auto Scaling Group ID |
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | Auto Scaling Group name |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | Launch Template ID |
| <a name="output_launch_template_latest_version"></a> [launch\_template\_latest\_version](#output\_launch\_template\_latest\_version) | Latest version of the Launch Template |
<!-- END_TF_DOCS -->