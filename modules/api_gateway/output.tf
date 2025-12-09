output "api_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.verdethos_api.id
}

output "api_endpoint" {
  description = "Invoke URL"
  value       = aws_apigatewayv2_api.verdethos_api.api_endpoint
}

output "stage_name" {
  description = "API Gateway stage name"
  value       = aws_apigatewayv2_stage.verdethos_api_stage.name
}

output "route_key" {
  description = "Route key of the default route"
  value       = aws_apigatewayv2_route.verdethos_api_route.route_key
}

output "integration_id" {
  description = "Lambda integration ID"
  value       = aws_apigatewayv2_integration.verdethos_api_integration.id
}

output "execution_arn" {
  description = "Execution ARN for API Gateway"
  value       = aws_apigatewayv2_api.verdethos_api.execution_arn
}
