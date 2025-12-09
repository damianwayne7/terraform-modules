variable "project_name" {
  description = "Project name (verdethos)"
  type        = string
}

variable "environment" {
  description = "Environment (stage|prod)"
  type        = string
}

variable "lambda_function_name" {
  type        = string
  description = "Lambda function name"
}

variable "lambda_source_path" {
  type        = string
  description = "Absolute or caller-relative path to lambda source directory (containing code). Must exist on the runner."
}


variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.11"
}

variable "handler" {
  description = "Function handler (module.function)"
  type        = string
  default     = "app.handler"
}

variable "memory_size" {
  description = "Memory (MB)"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Timeout (seconds)"
  type        = number
  default     = 10
}

variable "publish_version" {
  description = "Whether to publish a new version"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention days"
  type        = number
  default     = 14
}

# VPC (optional)
variable "vpc_subnet_ids" {
  description = "List of private subnet IDs to attach the Lambda to (for DB access)"
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "Security groups for Lambda when attached to VPC"
  type        = list(string)
  default     = []
}

# IAM role handling
variable "use_existing_role" {
  description = "If true, module will use var.existing_role_arn instead of creating a role"
  type        = bool
  default     = false
}

variable "existing_role_arn" {
  description = "ARN of an existing IAM role to use for the Lambda (required if use_existing_role = true)"
  type        = string
  default     = ""
}

variable "additional_managed_policy_arns" {
  description = "List of additional managed policy ARNs to attach to the created IAM role"
  type        = list(string)
  default     = []
}

# Environment variables (non-sensitive values OK here; sensitive should be injected via Secrets Manager or Parameter Store)
variable "environment_variables" {
  description = "Map of environment variables for the Lambda"
  type        = map(string)
  default     = {}
}

# Layers (ARNs)
variable "layers" {
  description = "List of Lambda layer ARNs"
  type        = list(string)
  default     = []
}

variable "description" {
  description = "Lambda description"
  type        = string
  default     = ""
}
