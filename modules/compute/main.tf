# Get latest Amazon Linux 2 AMI
data "aws_ssm_parameter" "ami" {
  name = var.ami_ssm_parameter
}

# Launch Template
resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ssm_parameter.ami.value
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [var.app_security_group_id]

  user_data = base64encode(var.user_data)

  iam_instance_profile {
    name = var.iam_instance_profile_name != "" ? var.iam_instance_profile_name : null
  }

  monitoring {
    enabled = var.enable_monitoring
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = var.require_imdsv2 ? "required" : "optional"
    http_put_response_hop_limit = 1
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      delete_on_termination = true
      encrypted             = var.enable_ebs_encryption
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        Name = "${var.project_name}-app-instance"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.tags,
      {
        Name = "${var.project_name}-app-volume"
      }
    )
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-launch-template"
    }
  )
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                      = "${var.project_name}-asg"
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = var.target_group_arns
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  enabled_metrics = var.enabled_metrics

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Policy - Scale Up
resource "aws_autoscaling_policy" "scale_up" {
  count                  = var.enable_autoscaling_policies ? 1 : 0
  name                   = "${var.project_name}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

# CloudWatch Alarm - High CPU
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count               = var.enable_autoscaling_policies ? 1 : 0
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.cpu_high_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_up[0].arn]

  tags = var.tags
}

# Auto Scaling Policy - Scale Down
resource "aws_autoscaling_policy" "scale_down" {
  count                  = var.enable_autoscaling_policies ? 1 : 0
  name                   = "${var.project_name}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

# CloudWatch Alarm - Low CPU
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  count               = var.enable_autoscaling_policies ? 1 : 0
  alarm_name          = "${var.project_name}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.cpu_low_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_down[0].arn]

  tags = var.tags
}
