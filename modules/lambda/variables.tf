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

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue to trigger populate lambda"
  type        = string
}

variable "dlq_arn" {
  description = "ARN of the related dead-letter queue for populate lambda"
  type        = string
}

variable "batch_size" {
  description = "Maximum number of records to process in a batch"
  type        = number
  default     = 1
}

variable "batch_window" {
  description = "Maximum time to wait before processing a batch in seconds"
  type        = number
  default     = 0
}

variable "max_concurrency" {
  description = "Maximum concurrency for Lambda scaling"
  type        = number
  default     = 10
}