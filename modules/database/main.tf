# Generate random password for RDS
resource "random_password" "master" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store DB credentials in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.project_name}-db-credentials"
  description = "Database master credentials"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-db-credentials"
    }
  )
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.master.result
    engine   = var.engine
    host     = aws_db_instance.main.address
    port     = aws_db_instance.main.port
    dbname   = var.database_name
  })

  depends_on = [aws_db_instance.main]
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "db-${var.project_name}-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "db-${var.project_name}-subnet-group"
    }
  )
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier     = "db-${var.project_name}"
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  iops                  = var.storage_type == "io1" || var.storage_type == "io2" ? var.iops : null

  db_name  = var.database_name
  username = var.db_username
  password = random_password.master.result
  port     = var.database_port

  vpc_security_group_ids = [var.db_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  publicly_accessible    = var.publicly_accessible

  multi_az          = var.multi_az
  availability_zone = var.multi_az ? null : var.availability_zone

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project_name}-db-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately

  copy_tags_to_snapshot = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-rds-instance"
    }
  )

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier,
      password
    ]
  }
}
