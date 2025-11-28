# API Gateway REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = "uni-project-api"
  description = "API Gateway for Lambda backend"
  tags        = var.tags
}

# /hello Resource
resource "aws_api_gateway_resource" "hello" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "hello"
}

# GET /hello
resource "aws_api_gateway_method" "hello_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = "GET"
  authorization = "NONE"
}

# Lambda Integration
resource "aws_api_gateway_integration" "hello_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.hello.id

  # Client method – must match the method resource
  http_method = aws_api_gateway_method.hello_get.http_method

  # Lambda invocation always POST
  integration_http_method = "POST"

  type = "AWS_PROXY"
  uri  = aws_lambda_function.backend_lambda.invoke_arn
}

# Allow API Gateway to call Lambda
resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backend_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# Deployment + Stage
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [
    aws_api_gateway_integration.hello_integration
  ]
}

resource "aws_api_gateway_stage" "prod" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
}

output "api_id" {
  value = aws_api_gateway_rest_api.api.id
}
