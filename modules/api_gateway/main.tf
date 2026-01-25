# modules/api_gateway/main.tf

resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-${var.env}-backend-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_credentials = false # false - instead, use allow_origins = ["*"]
    allow_headers = [
      "content-type",
      "x-bucket-name",
      "x-file-name",
      "x-models",
      "x-company-id",
      "x-user-id",
      "x-project-table-name",
      "x-client-side-id",
      "x-title",
      "x-description",
      "x-format",
      "x-size",
      "x-source-resolution-x",
      "x-source-resolution-y",
      "x-date-taken",
      "x-latitude",
      "x-longitude",
      "x-photo-index",
      "authorization",
      "x-amz-date",
      "x-api-key",
      "x-amz-security-token"
    ]
    allow_methods = ["POST", "OPTIONS"]
    allow_origins = ["*"]
    expose_headers = [
      "content-type",
      "x-bucket-name",
      "x-company-id",
      "x-date-taken",
      "x-file-name",
      "x-format",
      "x-models",
      "x-project-table-name",
      "x-title",
      "x-user-id",
      "x-photo-index"
    ]
    max_age = 300
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id = aws_apigatewayv2_api.main.id

  integration_type   = "AWS_PROXY"
  integration_uri    = var.lambda_backend_invoke_arn
  integration_method = "POST"

  payload_format_version = "2.0"
  timeout_milliseconds   = 30000
}

# TODO: Route & Stage configuration

# Stage configuration
resource "aws_apigatewayv2_stage" "main" {
  api_id = aws_apigatewayv2_api.main.id
  name   = var.stage_name

}