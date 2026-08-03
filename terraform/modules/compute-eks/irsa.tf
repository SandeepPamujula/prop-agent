# IRSA Role: Model Gateway (Bedrock access)
resource "aws_iam_role" "model_gateway_irsa" {
  name = "${var.cluster_name}-model-gateway-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:model-gateway:model-gateway-sa"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )
}

resource "aws_iam_policy" "bedrock_access" {
  name        = "${var.cluster_name}-bedrock-access-policy"
  description = "Policy allowing model gateway to invoke AWS Bedrock models"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "model_gateway_bedrock" {
  policy_arn = aws_iam_policy.bedrock_access.arn
  role       = aws_iam_role.model_gateway_irsa.name
}

# IRSA Role: Orchestrator
resource "aws_iam_role" "orchestrator_irsa" {
  name = "${var.cluster_name}-orchestrator-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:orchestrator:orchestrator-sa"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )
}
