variable "project_name" {
  description = "Project name (verdethos)"
  type        = string
}

variable "environment" {
  description = "Environment (stage | prod)"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Lambda invoke ARN (from lambda module)"
  type        = string
}

variable "route_key" {
  description = "API Gateway route key (e.g., 'GET /', 'POST /hello', '$default')"
  type        = string
  default     = "$default"
}

variable "stage_name" {
  description = "Custom stage name (defaults to environment)"
  type        = string
  default     = ""
}

variable "auto_deploy" {
  description = "Deploy API changes automatically"
  type        = bool
  default     = true
}

# -------- Optional: JWT Authorizer --------
variable "enable_jwt_authorizer" {
  description = "Enable JWT authorizer"
  type        = bool
  default     = false
}

variable "jwt_issuer" {
  description = "JWT issuer (required if JWT authorizer enabled)"
  type        = string
  default     = ""
}

variable "jwt_audience" {
  description = "JWT audience list"
  type        = list(string)
  default     = []
}
