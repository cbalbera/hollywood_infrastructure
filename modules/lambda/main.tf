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

}

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


}