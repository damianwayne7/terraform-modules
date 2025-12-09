output "lambda_function_name" {
  description = "Full Lambda function name"
  value       = aws_lambda_function.verdethos_lambda_function.function_name
}

output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.verdethos_lambda_function.arn
}

output "lambda_invoke_arn" {
  description = "Invoke ARN (useful for API Gateway permissions)"
  value       = aws_lambda_function.verdethos_lambda_function.invoke_arn
}

output "lambda_version" {
  description = "Published version (if publish_version=true)"
  value       = aws_lambda_function.verdethos_lambda_function.version
}

output "lambda_role_arn" {
  description = "Role ARN used by Lambda"
  value       = var.use_existing_role ? var.existing_role_arn : aws_iam_role.verdethos_lambda_role[0].arn
}
