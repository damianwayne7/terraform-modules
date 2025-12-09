locals {
  name_prefix      = "${var.project_name}-${var.environment}"
  cluster_identifier = "${local.name_prefix}-aurora-cluster"
  writer_instance_identifier = "${local.name_prefix}-aurora-writer"
  reader_instance_identifier_prefix = "${local.name_prefix}-aurora-reader"
  db_subnet_group_name = "${local.name_prefix}-db-subnet-group"
}

# DB Subnet Group
resource "aws_db_subnet_group" "verdethos_db_subnet_group" {
  name       = local.db_subnet_group_name
  subnet_ids = var.private_subnets
  tags = {
    Name        = local.db_subnet_group_name
    Project     = var.project_name
    Environment = var.environment
  }
}

# Optional KMS key pre-validated (module expects arn or id) - not created by module
# RDS Cluster
resource "aws_rds_cluster" "verdethos_aurora_cluster" {
  count                   = var.create_cluster ? 1 : 0
  cluster_identifier      = local.cluster_identifier
  engine                  = var.engine
  engine_version          = var.engine_version
  master_username         = var.master_username
  master_password         = var.master_password
  db_subnet_group_name    = aws_db_subnet_group.verdethos_db_subnet_group.name
  backup_retention_period = var.backup_retention_days
  preferred_backup_window = var.preferred_backup_window
  storage_encrypted       = var.storage_encrypted
  kms_key_id              = var.kms_key_id != "" ? var.kms_key_id : null
  skip_final_snapshot     = var.skip_final_snapshot
  apply_immediately       = var.apply_immediately

  # Optional: enable deletion protection for prod
  deletion_protection     = var.deletion_protection

  tags = {
    Name        = local.cluster_identifier
    Project     = var.project_name
    Environment = var.environment
  }
}

# Writer instance
resource "aws_rds_cluster_instance" "verdethos_aurora_writer" {
  count               = var.create_cluster ? 1 : 0
  identifier          = local.writer_instance_identifier
  cluster_identifier  = aws_rds_cluster.verdethos_aurora_cluster[0].id
  instance_class      = var.writer_instance_class
  engine              = aws_rds_cluster.verdethos_aurora_cluster[0].engine
  engine_version      = aws_rds_cluster.verdethos_aurora_cluster[0].engine_version
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.verdethos_db_subnet_group.name

  tags = {
    Name        = local.writer_instance_identifier
    Project     = var.project_name
    Environment = var.environment
  }
}

# Reader instances (optional)
resource "aws_rds_cluster_instance" "verdethos_aurora_reader" {
  count               = var.create_cluster ? var.reader_count : 0
  identifier          = "${local.reader_instance_identifier_prefix}-${count.index + 1}"
  cluster_identifier  = aws_rds_cluster.verdethos_aurora_cluster[0].id
  instance_class      = var.reader_instance_class
  engine              = aws_rds_cluster.verdethos_aurora_cluster[0].engine
  engine_version      = aws_rds_cluster.verdethos_aurora_cluster[0].engine_version
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.verdethos_db_subnet_group.name

  tags = {
    Name        = "${local.reader_instance_identifier_prefix}-${count.index + 1}"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Security: (optional) ensure SGs / IAM handled in env repo; not created here
