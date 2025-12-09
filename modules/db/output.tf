output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.verdethos_db_subnet_group.name
}

output "aurora_cluster_id" {
  description = "Aurora cluster identifier"
  value       = length(aws_rds_cluster.verdethos_aurora_cluster) > 0 ? aws_rds_cluster.verdethos_aurora_cluster[0].id : ""
}

output "aurora_writer_endpoint" {
  description = "Aurora writer endpoint"
  value       = length(aws_rds_cluster.verdethos_aurora_cluster) > 0 ? aws_rds_cluster.verdethos_aurora_cluster[0].endpoint : ""
}

output "aurora_reader_endpoint" {
  description = "Aurora reader endpoint (cluster reader endpoint)"
  value       = length(aws_rds_cluster.verdethos_aurora_cluster) > 0 ? aws_rds_cluster.verdethos_aurora_cluster[0].reader_endpoint : ""
}

output "aurora_cluster_arn" {
  description = "Aurora cluster ARN"
  value       = length(aws_rds_cluster.verdethos_aurora_cluster) > 0 ? aws_rds_cluster.verdethos_aurora_cluster[0].arn : ""
}
