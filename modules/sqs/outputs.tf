# sqs/outputs.tf

# Queue outputs
output "queue_arn" {
  description = "ARN of the populate queue"
  value       = aws_sqs_queue.populate_queue.arn
}

output "queue_url" {
  description = "URL of the populate queue"
  value       = aws_sqs_queue.populate_queue.url
}

# DLQ outputs
output "dlq_arn" {
  description = "ARN of the main DLQ"
  value       = var.enable_dlq ? aws_sqs_queue.populate_dlq.arn : null
}