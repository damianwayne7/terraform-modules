variable "project_name" {
  description = "Project name (ex: verdethos)"
  type        = string
}

variable "environment" {
  description = "Environment (stage | prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.10.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to create subnets in"
  type        = number
  default     = 2
}

variable "create_nat" {
  description = "Create NAT Gateways (true for prod, false for stage/dev)"
  type        = bool
  default     = true
}
