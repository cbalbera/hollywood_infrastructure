# sqs/main.tf

resource "aws_sqs_queue" "populate_queue" {
    name = "${var.project_name}-${var.env}-populate-queue"

    visibility_timeout_seconds = var.visibility_timeout
    message_retention_seconds  = var.retention_period
    delay_seconds              = var.delay_seconds
    max_message_size           = var.max_message_size
    receive_wait_time_seconds  = 20

    redrive_policy = var.enable_dlq ? jsonencode({
        deadLetterTargetArn = aws_sqs_queue.populate_dlq.arn
        maxReceiveCount     = coalesce(var.max_receive_count, 3)
    }) : null

    tags = {
        environment = var.env
        terraform   = "true"
    }
}

resource "aws_sqs_queue" "populate_dlq" {
    name = "${var.project_name}-${var.env}-populate-dlq"
    message_retention_seconds = var.dlq_retention_period
    receive_wait_time_seconds = 20

    tags = {
        environment = var.env
        type        = "dlq"
        terraform   = "true"
    }
}

# resource "aws_sqs_queue_policy" "populate_queue_policy" {

#   queue_url = aws_sqs_queue.populate_queue.url

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = concat([
#       {
#         Sid    = "AllowProcessorAccess"
#         Effect = "Allow"
#         Principal = {
#           AWS = [var.eks_role_arn]
#         }
#         Action = [
#           "sqs:ReceiveMessage",
#           "sqs:DeleteMessage",
#           "sqs:GetQueueAttributes",
#           "sqs:ChangeMessageVisibility"
#         ]
#         Resource = aws_sqs_queue.model_queues[each.key].arn
#       }
#       ],
#       length(var.additional_access_arns) > 0 ? [{
#         Sid    = "AllowAdditionalAccess"
#         Effect = "Allow"
#         Principal = {
#           AWS = var.additional_access_arns
#         }
#         Action = [
#           "sqs:SendMessage",
#           "sqs:ReceiveMessage",
#           "sqs:DeleteMessage",
#           "sqs:GetQueueAttributes",
#           "sqs:ChangeMessageVisibility"
#         ]
#         Resource = aws_sqs_queue.model_queues[each.key].arn
#       }] : []
#     )
#   })
# }

