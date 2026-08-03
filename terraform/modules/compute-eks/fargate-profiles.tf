resource "aws_iam_role" "fargate" {
  name = "${var.cluster_name}-fargate-execution-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )
}

resource "aws_iam_role_policy_attachment" "fargate_AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate.name
}

# Fargate Profile: kube-system
resource "aws_eks_fargate_profile" "kube_system" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "kube-system"
  pod_execution_role_arn = aws_iam_role.fargate.arn
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = "kube-system"
  }

  tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )
}

# Fargate Profile: Orchestrator
resource "aws_eks_fargate_profile" "orchestrator" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "orchestrator"
  pod_execution_role_arn = aws_iam_role.fargate.arn
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = "orchestrator"
  }

  tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )
}

# Fargate Profile: Model Gateway
resource "aws_eks_fargate_profile" "model_gateway" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "model-gateway"
  pod_execution_role_arn = aws_iam_role.fargate.arn
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = "model-gateway"
  }

  tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )
}

# Fargate Profile: MCP Server
resource "aws_eks_fargate_profile" "mcp_server" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "mcp-server"
  pod_execution_role_arn = aws_iam_role.fargate.arn
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = "mcp-server"
  }

  tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )
}
