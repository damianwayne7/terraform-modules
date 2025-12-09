variable "project_name" {
  description = "Project name (verdethos)"
  type        = string
}

variable "environment" {
  description = "Environment (stage|prod)"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs for DB subnet group"
  type        = list(string)
}

variable "create_cluster" {
  description = "Create Aurora cluster and instances"
  type        = bool
  default     = true
}

variable "engine" {
  description = "Aurora engine (aurora-postgresql | aurora-mysql)"
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version" {
  description = "Engine version"
  type        = string
  default     = "13.6"
}

variable "master_username" {
  description = "Master DB username"
  type        = string
  default     = "verdethos_admin"
}

variable "master_password" {
  description = "Master DB password (sensitive). Provide via tfvars or CI secret."
  type        = string
  sensitive   = true
  default     = ""
}

variable "backup_retention_days" {
  description = "Backup retention period in days (1-35)"
  type        = number
  default     = 7
  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 35
    error_message = "backup_retention_days must be between 1 and 35"
  }
}

variable "preferred_backup_window" {
  description = "Preferred daily backup window (hh24:mi-hh24:mi, UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "Optional KMS Key ID or ARN for storage encryption. Leave empty to use AWS-managed key."
  type        = string
  default     = ""
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot on destroy (set false for prod)"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply modifications immediately"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection on cluster (recommended for prod)"
  type        = bool
  default     = true
}

variable "writer_instance_class" {
  description = "Instance class for writer"
  type        = string
  default     = "db.r6g.large"
}

variable "reader_instance_class" {
  description = "Instance class for reader instances"
  type        = string
  default     = "db.r6g.large"
}

variable "reader_count" {
  description = "Number of reader instances to create"
  type        = number
  default     = 1
}
