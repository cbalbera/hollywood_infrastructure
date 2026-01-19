variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "env" {
  description = "Environment (dev, qa, prod, shared)"
  type        = string
}

variable "tags" {
  description = "Tags for lambdas"
  type        = map(string)
  default     = {}
}

variable "memory_size" {
  type        = number
  description = "Lambda memory size"
  default     = 1024
}

variable "timeout" {
  type        = number
  description = "Lambda timeout"
  default     = 30
}

variable "ecr_repository_url" {
  type        = string
  description = "Base URL for ECR repositories"
}

variable "image_version" {
  description = "The tag for the container image"
  type        = string
  default     = "latest"
}

variable "db_name" {
  description = "The name of the database used for connection, provided in tfvars per environment"
  type        = string
  # default     = "placeholder"
}

variable "db_pwd" {
  description = "The password for the database used for connection, provided in tfvars per environment"
  type        = string
  # default     = "placeholder"
}

variable "db_host" {
  description = "The host for the database used for connection, provided in tfvars per environment"
  type        = string
  # default     = "placeholder"
}

variable "db_user" {
  description = "The username for the database used for connection, provided in tfvars per environment"
  type        = string
  # default     = "placeholder"
}