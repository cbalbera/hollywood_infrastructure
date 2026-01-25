variable "project_name" {
  description = "Project name"
  type        = string
  default     = "hollywood"
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "qa"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = number
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "db_name" {
  description = "The name of the database used for connection, provided in tfvars per environment"
  type        = string
  default     = "placeholder"
}

variable "db_pwd" {
  description = "The password for the database used for connection, provided in tfvars per environment"
  type        = string
  default     = "placeholder"
}

variable "db_host" {
  description = "The host for the database used for connection, provided in tfvars per environment"
  type        = string
  default     = "placeholder"
}

variable "db_user" {
  description = "The username for the database used for connection, provided in tfvars per environment"
  type        = string
  default     = "placeholder"
}