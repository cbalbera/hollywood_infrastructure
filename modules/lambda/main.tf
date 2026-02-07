locals {
    lambda_api_functions = {
        "l-backend"       = "l_backend"
    }

    lambda_sqs_trigger_functions = {
      "l-populate"      = "l_populate"
    }

    repository_base_url = var.ecr_repository_url 

    # Normalize tags for consistency
    normalized_tags = merge(var.tags, {
        Environment = var.env
        Project     = var.project_name
        ManagedBy   = "terraform"
    })

    # suffix = var.use_suffix ? "-${random_id.suffix.hex}" : ""

}

# resource "random_id" "suffix" {
#     byte_length = 8
# }

resource "aws_lambda_function" "rest_api" {
    for_each = local.lambda_api_functions

    function_name = "${var.project_name}-${var.env}-${each.key}"
    role          = aws_iam_role.rest_api_role[each.key].arn

    package_type = "Image"
    image_uri    = "${local.repository_base_url}-${each.key}:${var.image_version}"

    memory_size = var.memory_size
    timeout     = var.timeout

    environment {
        variables = {
            ENVIRONMENT                     = var.env
            DB_NAME                         = var.db_name
            DB_PWD                          = var.db_pwd
            DB_HOST                         = var.db_host
            DB_USER                         = var.db_user
            POPULATE_DATABASE_SQS_QUEUE_URL = var.populate_sql_queue_url
            TMDB_API_KEY                    = var.tmdb_api_key
            LOG_LEVEL                       = var.lambda_log_level
        }
    }

    depends_on = [aws_iam_role.rest_api_role, aws_cloudwatch_log_group.cloudwatch_log_group_rest_api]

}

resource "aws_lambda_function" "sqs_trigger" {
    for_each = local.lambda_sqs_trigger_functions

    function_name = "${var.project_name}-${var.env}-${each.key}"
    role          = aws_iam_role.sqs_trigger_role[each.key].arn

    package_type = "Image"
    image_uri    = "${local.repository_base_url}-${each.key}:${var.image_version}"

    memory_size = var.memory_size
    timeout     = var.timeout

    environment {
        variables = {
            ENVIRONMENT                     = var.env
            DB_NAME                         = var.db_name
            DB_PWD                          = var.db_pwd
            DB_HOST                         = var.db_host
            DB_USER                         = var.db_user
            POPULATE_DATABASE_SQS_QUEUE_URL = var.populate_sql_queue_url
            TMDB_API_KEY                    = var.tmdb_api_key
            LOG_LEVEL                       = var.lambda_log_level
        }
    }

    depends_on = [aws_iam_role.sqs_trigger_role, aws_cloudwatch_log_group.cloudwatch_log_group_sqs_trigger]

}


resource "aws_iam_role" "rest_api_role" {
    for_each = local.lambda_api_functions

    name = "${var.project_name}-${var.env}-${each.key}-rest-api-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
            Service = "lambda.amazonaws.com"
            }
        }]
    })

    tags = merge(local.normalized_tags, {
        Name  = "${var.project_name}-${var.env}-${each.key}-rest-api--role"
        Model = each.key
    })
}

resource "aws_iam_role" "sqs_trigger_role" {
    for_each = local.lambda_sqs_trigger_functions

    name = "${var.project_name}-${var.env}-${each.key}-sqs-trigger-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
            Service = "lambda.amazonaws.com"
            }
        }]
    })

    tags = merge(local.normalized_tags, {
        Name  = "${var.project_name}-${var.env}-${each.key}-sqs-trigger-role"
        Model = each.key
    })
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  for_each = local.lambda_sqs_trigger_functions

  event_source_arn                   = var.sqs_queue_arn
  function_name                      = aws_lambda_function.sqs_trigger[each.key].arn
  batch_size                         = var.batch_size
  maximum_batching_window_in_seconds = var.batch_window
  enabled                            = true

  scaling_config {
    maximum_concurrency = var.max_concurrency
  }

  function_response_types = ["ReportBatchItemFailures"]
}

# required for a number of everyday operations, including writing to CloudWatch logs
resource "aws_iam_role_policy_attachment" "basic_execution_lambda_rest_api" {
  for_each = local.lambda_api_functions

  role       = aws_iam_role.rest_api_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "basic_execution_lambda_sqs_trigger" {
  for_each = local.lambda_sqs_trigger_functions

  role       = aws_iam_role.sqs_trigger_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "sqs_policy_lambda_api" {
  for_each = local.lambda_api_functions

  name = "${var.project_name}-${var.env}-${each.key}-sqs-policy"
  role = aws_iam_role.rest_api_role[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = var.sqs_queue_arn
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueUrl"
        ]
        Resource = var.dlq_arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "sqs_policy_lambda_sqs_triggered" {
  for_each = local.lambda_sqs_trigger_functions

  name = "${var.project_name}-${var.env}-${each.key}-sqs-policy"
  role = aws_iam_role.sqs_trigger_role[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = var.sqs_queue_arn
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueUrl"
        ]
        Resource = var.dlq_arn
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group_rest_api" {
  for_each = local.lambda_api_functions
  name = "/aws/lambda/hollywood-${var.env}-${each.key}"

  retention_in_days = 7

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group_sqs_trigger" {
  for_each = local.lambda_sqs_trigger_functions
  name = "/aws/lambda/hollywood-${var.env}-${each.key}"

  retention_in_days = 7

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
}