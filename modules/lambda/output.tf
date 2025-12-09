output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.verdethos_lambda_function.function_name
}

output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.verdethos_lambda_function.arn
}

output "lambda_log_group_name" {
  value = aws_cloudwatch_log_group.verdethos_lambda_log_group.name
}
