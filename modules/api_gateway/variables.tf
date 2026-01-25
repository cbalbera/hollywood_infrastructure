# modules/api_gateway/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "lambda_backend_invoke_arn" {
  description = "ARN for invoking the Lambda function"
  type        = string
}

variable "lambda_backend_function_name" {
  description = "Lambda function name"
  type        = string
}

variable "stage_name" {
  description = "Name of the API Gateway stage"
  type        = string
  default     = "v1"
}