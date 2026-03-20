# modules/eks/main.tf

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name   # injected ✅
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids = var.subnet_ids  # injected from networking ✅
  }

  tags = {
    Name        = var.cluster_name
    Environment = var.environment
  }
}

resource "aws_iam_role" "cluster" {
  name = "eks-cluster-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "nodes-${var.environment}"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids  # injected ✅

  instance_types = [var.node_instance_type]  # injected ✅

  capacity_type = var.enable_spot_instances ? "SPOT" : "ON_DEMAND"  # injected ✅

  scaling_config {
    desired_size = var.desired_node_count  # injected ✅
    min_size     = var.min_node_count
    max_size     = var.max_node_count
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role" "node" {
  name = "eks-node-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}