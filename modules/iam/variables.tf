variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the database secret in Secrets Manager"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
