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

##############################################
# IAM ROLE FOR EKS CONTROL PLANE
##############################################

data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name               = local.cluster_role_name
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json

  tags = {
    Name        = local.cluster_role_name
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

##############################################
# EKS CLUSTER
##############################################

resource "aws_eks_cluster" "eks_cluster" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
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
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy
  ]
}


##############################################
# OIDC PROVIDER FOR IRSA
##############################################

data "tls_certificate" "eks_oidc_thumbprint" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc_thumbprint.certificates[0].sha1_fingerprint]
}


##############################################
# EKS NODE ROLE
##############################################

data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node_role" {
  name               = local.node_role_name
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json

  tags = {
    Name        = local.node_role_name
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "eks_node_worker_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_node_ecr_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


##############################################
# MANAGED NODE GROUP (Optional)
##############################################

resource "aws_eks_node_group" "eks_node_group" {
  count = var.create_node_group ? 1 : 0

  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = local.node_group_name
  node_role_arn   = aws_iam_role.eks_node_role.arn
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
