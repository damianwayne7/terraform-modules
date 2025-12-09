##############################################
# EKS MODULE WITH PROPER RESOURCE NAMING
# verdethos-<env>-eks-*
##############################################

locals {
  prefix        = "${var.project_name}-${var.environment}"
  cluster_name  = "${local.prefix}-eks-cluster"
  node_role_name = "${local.prefix}-eks-node-role"
  cluster_role_name = "${local.prefix}-eks-cluster-role"
  node_group_name = "${local.prefix}-eks-node-group"
}

#################################################
# IAM ROLE FOR EKS CONTROL PLANE
#################################################
data "aws_iam_policy_document" "verdethos_eks_cluster_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "verdethos_eks_cluster_role" {
  name               = local.cluster_role_name
  assume_role_policy = data.aws_iam_policy_document.verdethos_eks_cluster_assume.json

  tags = {
    Name        = local.cluster_role_name
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "verdethos_eks_cluster_policy" {
  role       = aws_iam_role.verdethos_eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "verdethos_eks_service_policy" {
  role       = aws_iam_role.verdethos_eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

#################################################
# EKS CLUSTER
#################################################
resource "aws_eks_cluster" "verdethos_eks_cluster" {
  name     = local.cluster_name
  role_arn = aws_iam_role.verdethos_eks_cluster_role.arn
  version  = var.k8s_version

  vpc_config {
    subnet_ids              = var.private_subnets
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  tags = {
    Name        = local.cluster_name
    Project     = var.project_name
    Environment = var.environment
  }

  depends_on = [
    aws_iam_role_policy_attachment.verdethos_eks_cluster_policy,
    aws_iam_role_policy_attachment.verdethos_eks_service_policy
  ]
}

#################################################
# IAM OIDC PROVIDER FOR IRSA
#################################################
data "tls_certificate" "verdethos_eks_oidc_thumbprint" {
  url = aws_eks_cluster.verdethos_eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "verdethos_eks_oidc" {
  url             = aws_eks_cluster.verdethos_eks_cluster.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.verdethos_eks_oidc_thumbprint.certificates[0].sha1_fingerprint]
}

#################################################
# NODE ROLE
#################################################
data "aws_iam_policy_document" "verdethos_eks_node_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "verdethos_eks_node_role" {
  name               = local.node_role_name
  assume_role_policy = data.aws_iam_policy_document.verdethos_eks_node_assume.json

  tags = {
    Name        = local.node_role_name
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "verdethos_eks_node_worker" {
  role       = aws_iam_role.verdethos_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "verdethos_eks_node_cni" {
  role       = aws_iam_role.verdethos_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "verdethos_eks_node_ecr" {
  role       = aws_iam_role.verdethos_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

#################################################
# MANAGED NODE GROUP
#################################################
resource "aws_eks_node_group" "verdethos_eks_node_group" {
  cluster_name    = aws_eks_cluster.verdethos_eks_cluster.name
  node_group_name = local.node_group_name
  node_role_arn   = aws_iam_role.verdethos_eks_node_role.arn
  subnet_ids      = var.private_subnets

  scaling_config {
    desired_size = var.node_desired
    min_size     = var.node_min
    max_size     = var.node_max
  }

  instance_types = var.instance_types
  ami_type       = var.node_ami_type

  tags = {
    Name        = local.node_group_name
    Project     = var.project_name
    Environment = var.environment
  }
}
