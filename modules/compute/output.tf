##############################################
# EKS Cluster Outputs
##############################################

output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_ca" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "cluster_security_group_id" {
  value = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

##############################################
# Node Group Outputs
##############################################

output "eks_node_group_name" {
  value = try(aws_eks_node_group.eks_node_group[0].node_group_name, "")
}

output "eks_node_group_arn" {
  value = try(aws_eks_node_group.eks_node_group[0].arn, "")
}

output "node_security_group_ids" {
  value = try(aws_eks_node_group.eks_node_group[0].resources[*].security_group_ids, [])
}

##############################################
# OIDC Provider
##############################################

output "eks_cluster_oidc_arn" {
  value = aws_iam_openid_connect_provider.eks_oidc.arn
}
