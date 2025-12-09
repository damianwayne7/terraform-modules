output "eks_cluster_name" {
  value = aws_eks_cluster.verdethos_eks_cluster.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.verdethos_eks_cluster.endpoint
}

output "eks_cluster_ca" {
  value = aws_eks_cluster.verdethos_eks_cluster.certificate_authority[0].data
}

output "eks_node_group_name" {
  value = aws_eks_node_group.verdethos_eks_node_group.node_group_name
}

output "eks_node_group_arn" {
  value = aws_eks_node_group.verdethos_eks_node_group.arn
}

output "eks_cluster_oidc_arn" {
  value = aws_iam_openid_connect_provider.verdethos_eks_oidc.arn
}
