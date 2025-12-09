variable "project_name"     { type = string }
variable "environment"      { type = string }

variable "vpc_id"           { type = string }
variable "private_subnets"  { type = list(string) }
variable "public_subnets"   { type = list(string) }

variable "k8s_version" {
  type    = string
  default = "1.28"
}

variable "endpoint_private_access" {
  type    = bool
  default = false
}

variable "endpoint_public_access" {
  type    = bool
  default = true
}

variable "public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_ami_type" {
  type    = string
  default = "AL2_x86_64"
}

variable "node_desired" {
  type    = number
  default = 2
}

variable "node_min" {
  type    = number
  default = 1
}

variable "node_max" {
  type    = number
  default = 3
}
