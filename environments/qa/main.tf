module "ecr" {
    source = "./../../modules/ecr"

    project_name = var.project_name
    env          = var.env
}

module "lambda" {
    source = "./../../modules/lambda"

    project_name        = var.project_name
    env                 = var.env
    ecr_repository_url  = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-${var.env}"
    sqs_queue_arn       = module.sqs.queue_arn
    dlq_arn             = module.sqs.dlq_arn

    # tfvars
    db_name      = var.db_name
    db_pwd       = var.db_pwd
    db_host      = var.db_host
    db_user      = var.db_user
}

module "sqs" {
    source = "./../../modules/sqs"
    project_name        = var.project_name
    env                 = var.env
    aws_account_id      = var.aws_account_id
}

module "api_gateway" {
    source = "../../modules/api_gateway"

    project_name                 = var.project_name
    env                          = var.env
    lambda_backend_invoke_arn    = module.lambda.lambda_backend_invoke_arn
    lambda_backend_function_name = module.lambda.lambda_backend_function_name

}