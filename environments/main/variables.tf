variable "project_name" {
  description = "Project name"
  type        = string
  default     = "hollywood"
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "main"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

