# ECR Repository for NoteService
resource "aws_ecr_repository" "noteservice" {
  name                 = "${var.project_name}-${var.repository_name}"
  image_tag_mutability = var.image_tag_mutability
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = var.enable_image_scanning
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.kms_key_arn
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.repository_name}"
    }
  )
}

# Lifecycle policy to clean up old images
resource "aws_ecr_lifecycle_policy" "policy" {
  count      = var.enable_lifecycle_policy ? 1 : 0
  repository = aws_ecr_repository.noteservice.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${var.max_image_count} images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = var.max_image_count
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Remove untagged images older than ${var.untagged_image_retention_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.untagged_image_retention_days
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Repository policy for cross-account access (optional)
resource "aws_ecr_repository_policy" "policy" {
  count      = var.enable_cross_account_access ? 1 : 0
  repository = aws_ecr_repository.noteservice.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPull"
        Effect = "Allow"
        Principal = {
          AWS = var.allowed_principals
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}
