locals {
  name_prefix      = "${var.project_name}-${var.environment}"
  lambda_name      = "${local.name_prefix}-lambda-${var.lambda_function_name}"
  lambda_role_name = "${local.name_prefix}-lambda-${var.lambda_function_name}-role"
  log_group_name   = "/aws/lambda/${local.lambda_name}"
}

# -------------------------------
# IAM ROLE
# -------------------------------
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  count              = var.use_existing_role ? 0 : 1
  name               = local.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json

  tags = {
    Name        = local.lambda_role_name
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  count      = var.use_existing_role ? 0 : 1
  role       = aws_iam_role.lambda_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

locals {
  lambda_role_arn = var.use_existing_role ? var.existing_role_arn : aws_iam_role.lambda_role[0].arn
}

# -------------------------------
# Source ZIP selection logic
# -------------------------------
locals {
  final_zip_path = var.zip_file_path != "" ?
    var.zip_file_path :
    "${path.module}/build/${var.lambda_function_name}.zip"
}

# Only build zip if ZIP not provided
resource "null_resource" "ensure_build_dir" {
  count = var.zip_file_path == "" ? 1 : 0
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/build"
  }
}

data "archive_file" "lambda_zip" {
  count       = var.zip_file_path == "" ? 1 : 0
  type        = "zip"
  source_dir  = var.lambda_source_path
  output_path = local.final_zip_path
}

# -------------------------------
# CloudWatch log group
# -------------------------------
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = local.log_group_name
  retention_in_days = var.log_retention_days
}

# -------------------------------
# Lambda Function
# -------------------------------
resource "aws_lambda_function" "lambda" {
  function_name = local.lambda_name
  handler       = var.handler
  runtime       = var.runtime
  role          = local.lambda_role_arn
  timeout       = var.timeout
  memory_size   = var.memory_size
  publish       = var.publish_version

  filename = local.final_zip_path

  source_code_hash = var.zip_file_path != "" ?
    filebase64sha256(var.zip_file_path) :
    data.archive_file.lambda_zip[0].output_base64sha256

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    for_each = length(var.vpc_subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

  layers = var.layers

  tags = {
    Name        = local.lambda_name
    Project     = var.project_name
    Environment = var.environment
  }
}
