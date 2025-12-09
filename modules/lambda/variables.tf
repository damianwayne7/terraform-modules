variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

# FUNCTION NAME (required)
variable "lambda_function_name" {
  type        = string
  description = "Logical name of the lambda function"
}

# --- 2 ways to provide code ----
# A) Prebuilt ZIP (recommended)
variable "zip_file_path" {
  type        = string
  description = "Path to an existing Lambda deployment ZIP"
  default     = ""
}

# B) Source directory (optional, fallback)
variable "lambda_source_path" {
  type        = string
  description = "Path to folder containing lambda source code. Ignored if zip_file_path is set."
  default     = ""
}

variable "handler" {
  type    = string
  default = "hello.handler"
}

variable "runtime" {
  type    = string
  default = "python3.11"
}

variable "memory_size" {
  type    = number
  default = 128
}

variable "timeout" {
  type    = number
  default = 10
}

variable "publish_version" {
  type    = bool
  default = false
}

variable "log_retention_days" {
  type    = number
  default = 14
}

variable "use_existing_role" {
  type    = bool
  default = false
}

variable "existing_role_arn" {
  type    = string
  default = ""
}

variable "additional_managed_policy_arns" {
  type    = list(string)
  default = []
}

variable "vpc_subnet_ids" {
  type    = list(string)
  default = []
}

variable "vpc_security_group_ids" {
  type    = list(string)
  default = []
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "layers" {
  type    = list(string)
  default = []
}
