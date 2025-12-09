##############################################
# EKS Cluster Outputs
##############################################

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.verdethos_eks_cluster.name
}

output "eks_cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = aws_eks_cluster.verdethos_eks_cluster.endpoint
}

output "eks_cluster_ca" {
  description = "Base64 encoded Cluster CA certificate"
  value       = aws_eks_cluster.verdethos_eks_cluster.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS control plane"
  value       = aws_eks_cluster.verdethos_eks_cluster.vpc_config[0].cluster_security_group_id
}


##############################################
# Node Group Outputs (Safe even if count = 0)
##############################################

output "eks_node_group_name" {
  description = "Node group name (empty if node group not created)"
  value       = try(aws_eks_node_group.verdethos_eks_node_group[0].node_group_name, "")
}

output "eks_node_group_arn" {
  description = "Node group ARN (empty if node group not created)"
  value       = try(aws_eks_node_group.verdethos_eks_node_group[0].arn, "")
}


##############################################
# Node Security Groups for ALB Integration
##############################################

output "node_security_group_ids" {
  description = "List of security groups used by worker nodes"
  value       = try(aws_eks_node_group.verdethos_eks_node_group[0].resources[*].security_group_ids, [])
}


##############################################
# OIDC Provider Output
##############################################

output "eks_cluster_oidc_arn" {
  description = "IAM OIDC provider ARN for IRSA"
  value       = aws_iam_openid_connect_provider.verdethos_eks_oidc.arn
}
