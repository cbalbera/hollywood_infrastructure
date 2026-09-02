# modules/api_gateway/main.tf

resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-${var.env}-backend-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_credentials = false # false - instead, use allow_origins = ["*"]
    allow_headers = [
      "content-type",
      "authorization",
      "x-amz-date",
      "x-amz-security-token"
    ]
    # "ANY" is a route key, not an HTTP method - API Gateway rejects it here.
    # Without allow_methods, preflight responses omit Access-Control-Allow-Methods
    # and browsers block every non-simple request.
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_origins = ["*"]
    expose_headers = [
      "content-type"
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

# Route configuration
resource "aws_apigatewayv2_route" "upload" {
  for_each = toset(var.route_configurations.backend_route)

  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /${each.value}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}



# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/apigateway/${var.project_name}-${var.env}-upload-api"
  retention_in_days = 365
}

# Stage configuration
resource "aws_apigatewayv2_stage" "main" {
  api_id = aws_apigatewayv2_api.main.id
  name   = var.stage_name

  auto_deploy = true

  default_route_settings {
    detailed_metrics_enabled = true
    throttling_burst_limit   = 20000
    throttling_rate_limit    = 30000
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format = jsonencode({
      requestId          = "$context.requestId"
      ip                 = "$context.identity.sourceIp"
      requestTime        = "$context.requestTime"
      httpMethod         = "$context.httpMethod"
      routeKey           = "$context.routeKey"
      status             = "$context.status"
      protocol           = "$context.protocol"
      responseLength     = "$context.responseLength"
      integrationError   = "$context.integrationErrorMessage"
      integrationLatency = "$context.integrationLatency"
    })
  }
}

resource "aws_lambda_permission" "api_gateway" {
  for_each = toset(var.route_configurations.backend_route)

  statement_id  = "AllowAPIGatewayInvoke-${title(var.env)}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_backend_function_name
  principal     = "apigateway.amazonaws.com"
  # unable to specify stage name (as each.name) because the name includes special chars - "{proxy+}" - so wildcards used instead
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*/*"
}