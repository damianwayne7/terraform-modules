locals {
  name_prefix    = "${var.project_name}-${var.environment}"
  lambda_name    = "${local.name_prefix}-lambda-${var.function_name}"
  lambda_role_name = "${local.name_prefix}-lambda-${var.function_name}-role"
  log_group_name = "/aws/lambda/${local.lambda_name}"
}

# ------------------------------------------------
# IAM Role (optional: created only if var.use_existing_role = false)
# ------------------------------------------------
data "aws_iam_policy_document" "verdethos_lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "verdethos_lambda_role" {
  count = var.use_existing_role ? 0 : 1
  name  = local.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.verdethos_lambda_assume.json

  tags = {
    Name        = local.lambda_role_name
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "verdethos_lambda_basic_execution" {
  count = var.use_existing_role ? 0 : 1
  role  = aws_iam_role.verdethos_lambda_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach additional managed policies if requested
resource "aws_iam_role_policy_attachment" "verdethos_lambda_extra_policies" {
  count = var.use_existing_role ? 0 : length(var.additional_managed_policy_arns)
  role  = aws_iam_role.verdethos_lambda_role[0].name
  policy_arn = var.additional_managed_policy_arns[count.index]
}

# If user provides an existing role ARN, we will use it; otherwise use created role
locals {
  lambda_role_arn = var.use_existing_role ? var.existing_role_arn : aws_iam_role.verdethos_lambda_role[0].arn
}

resource "null_resource" "ensure_build_dir" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/build"
  }
}
# ------------------------------------------------
# Package Lambda source (zip)
# ------------------------------------------------
data "archive_file" "verdethos_lambda_zip" {
  type        = "zip"
  source_dir  = var.source_path
  output_path = "${path.module}/build/${var.lambda_function_name}.zip"
}

# ------------------------------------------------
# CloudWatch log group
# ------------------------------------------------
resource "aws_cloudwatch_log_group" "verdethos_lambda_log_group" {
  name              = local.log_group_name
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${local.log_group_name}"
    Project     = var.project_name
    Environment = var.environment
  }
}

# ------------------------------------------------
# Lambda function
# ------------------------------------------------
resource "aws_lambda_function" "verdethos_lambda_function" {
  function_name = local.lambda_name
  filename      = data.archive_file.verdethos_lambda_zip.output_path
  source_code_hash = data.archive_file.verdethos_lambda_zip.output_base64sha256
  handler       = var.handler
  runtime       = var.runtime
  role          = local.lambda_role_arn
  publish       = var.publish_version
  memory_size   = var.memory_size
  timeout       = var.timeout
  description   = var.description

  # Optional: VPC configuration (for DB access)
  vpc_config {
    subnet_ids         = var.vpc_subnet_ids
    security_group_ids = var.vpc_security_group_ids
  }

  environment {
    variables = var.environment_variables
  }

  layers = var.layers

  tags = {
    Name        = local.lambda_name
    Project     = var.project_name
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

