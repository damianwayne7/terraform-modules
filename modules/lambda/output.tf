output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.lambda.function_name
}

output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.lambda.arn
}

output "lambda_log_group_name" {
  description = "CloudWatch log group name for the lambda"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}
