variable "project_name" {
  description = "Project name (verdethos)"
  type        = string
}

variable "environment" {
  description = "Environment (stage|prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet IDs (optional)"
  type        = list(string)
  default     = []
}

variable "internal" {
  description = "Whether ALB is internal"
  type        = bool
  default     = false
}

variable "listener_protocol" {
  description = "Listener protocol (HTTP/HTTPS)"
  type        = string
  default     = "HTTP"
}

variable "listener_port" {
  description = "Port the listener listens on"
  type        = number
  default     = 80
}

variable "target_protocol" {
  description = "Target group protocol (HTTP/HTTPS)"
  type        = string
  default     = "HTTP"
}

variable "target_port" {
  description = "Target group port"
  type        = number
  default     = 80
}

variable "target_type" {
  description = "Target type for target group: instance | ip | lambda"
  type        = string
  default     = "instance"
}

variable "health_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "health_matcher" {
  description = "Health check matcher (200-399)"
  type        = string
  default     = "200-399"
}

variable "health_interval" {
  description = "Health check interval (seconds)"
  type        = number
  default     = 30
}

variable "health_timeout" {
  description = "Health check timeout (seconds)"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Healthy threshold"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Unhealthy threshold"
  type        = number
  default     = 2
}

variable "enable_https" {
  description = "Enable HTTPS listener"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "Certificate ARN for HTTPS listener (required if enable_https=true)"
  type        = string
  default     = ""
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}

variable "allowed_cidrs" {
  description = "CIDR blocks allowed to access ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "create_static_targets" {
  description = "If true, register items in var.targets with the target group"
  type        = bool
  default     = false
}

variable "targets" {
  description = <<EOF
Optional list of targets to register with the target group.
Each item must be an object: { target_id = string, port = number (optional) }
- For instance targets use the instance id.
- For ip targets use IP address.
- For lambda targets use Lambda function ARN.
EOF
  type = list(object({
    target_id = string
    port      = number
  }))
  default = []
}

variable "enable_access_logs" {
  description = "Enable ALB access logs to S3"
  type        = bool
  default     = false
}

variable "access_logs_bucket_name" {
  description = "Existing S3 bucket name for access logs. If empty a bucket name will be generated (not recommended in this module)."
  type        = string
  default     = ""
}
