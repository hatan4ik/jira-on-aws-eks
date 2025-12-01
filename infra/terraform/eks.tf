# Minimal EKS cluster example. In production you would likely use a battle-tested module like terraform-aws-eks.

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_eks_cluster" "this" {
  name     = "${var.project_name}-eks"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = module.network.private_subnet_ids
  }

  depends_on = [aws_iam_role.eks_cluster_role]
}

resource "aws_iam_role" "eks_node_role" {
  name = "${var.project_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_eks_node_group" "jira_nodes" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project_name}-jira-ng"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = module.network.private_subnet_ids

  scaling_config {
    desired_size = 3
    min_size     = 2
    max_size     = 6
  }

  instance_types = ["m5.xlarge"]
}

output "cluster_name" {
  value = aws_eks_cluster.this.name
}
