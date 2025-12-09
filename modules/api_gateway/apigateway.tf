locals {
  prefix             = "${var.project_name}-${var.environment}"
  api_name           = "${local.prefix}-apigw"
  integration_name   = "${local.prefix}-apigw-integration"
  route_name         = "${local.prefix}-apigw-route"
  stage_name         = var.stage_name != "" ? var.stage_name : var.environment
}

##############################################################
# API Gateway HTTP API
##############################################################
resource "aws_apigatewayv2_api" "verdethos_api" {
  name          = local.api_name
  protocol_type = "HTTP"

  tags = {
    Name        = local.api_name
    Project     = var.project_name
    Environment = var.environment
  }
}

##############################################################
# Optional: JWT Authorizer (disabled unless variables set)
##############################################################
resource "aws_apigatewayv2_authorizer" "verdethos_jwt_authorizer" {
  count               = var.enable_jwt_authorizer ? 1 : 0
  api_id              = aws_apigatewayv2_api.verdethos_api.id
  name                = "${local.prefix}-jwt-authorizer"
  authorizer_type     = "JWT"
  identity_sources     = ["$request.header.Authorization"]

  jwt_configuration {
    audience = var.jwt_audience
    issuer   = var.jwt_issuer
  }
}

##############################################################
# Lambda integration
##############################################################
resource "aws_apigatewayv2_integration" "verdethos_api_integration" {
  api_id                    = aws_apigatewayv2_api.verdethos_api.id
  integration_type          = "AWS_PROXY"
  integration_uri           = var.lambda_invoke_arn
  payload_format_version    = "2.0"
  integration_method        = "POST"

  description = "${local.integration_name}"

  # No tags supported on integrations
}

##############################################################
# Route
##############################################################
resource "aws_apigatewayv2_route" "verdethos_api_route" {
  api_id    = aws_apigatewayv2_api.verdethos_api.id
  route_key = var.route_key

  target = "integrations/${aws_apigatewayv2_integration.verdethos_api_integration.id}"

  # Authorizer if enabled
  authorizer_id = var.enable_jwt_authorizer ? aws_apigatewayv2_authorizer.verdethos_jwt_authorizer[0].id : null
}

##############################################################
# Stage
##############################################################
resource "aws_apigatewayv2_stage" "verdethos_api_stage" {
  api_id     = aws_apigatewayv2_api.verdethos_api.id
  name       = local.stage_name
  auto_deploy = var.auto_deploy

  tags = {
    Name        = "${local.prefix}-apigw-stage-${local.stage_name}"
    Project     = var.project_name
    Environment = var.environment
  }
}

##############################################################
# Lambda Permission: allow API Gateway to invoke Lambda
##############################################################
resource "aws_lambda_permission" "verdethos_apigw_permission" {
  statement_id  = "${local.prefix}-apigw-permission"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_invoke_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.verdethos_api.execution_arn}/*/*"
}
