output "lambda_backend_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.processor["l-backend"].function_name
}

output "lambda_backend_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.processor["l-backend"].invoke_arn
}