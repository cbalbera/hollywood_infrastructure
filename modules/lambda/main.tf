locals {
    lambda_functions = {
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

resource "aws_lambda_function" "processor" {
    for_each = local.lambda_functions

    function_name = "${var.project_name}-${var.env}-${each.key}"
    role          = aws_iam_role.processor_role[each.key].arn

    package_type = "Image"
    image_uri    = "${local.repository_base_url}-${each.key}:${var.image_version}"

    memory_size = var.memory_size
    timeout     = var.timeout

    environment {
        variables = {
            ENVIRONMENT    = var.env
            DB_NAME        = var.db_name
            DB_PWD         = var.db_pwd
            DB_HOST        = var.db_host
            DB_USER        = var.db_user
        }
    }

    depends_on = [aws_iam_role.processor_role]

}

resource "aws_iam_role" "processor_role" {
    for_each = local.lambda_functions

    name = "${var.project_name}-${var.env}-${each.key}-role"

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
        Name  = "${var.project_name}-${var.env}-${each.key}-role"
        Model = each.key
    })
}