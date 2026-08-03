# MongoDB Connection URI Secret
resource "aws_secretsmanager_secret" "mongodb_uri" {
  name        = "prop-agent-${var.environment}-mongodb-uri"
  description = "MongoDB Atlas connection URI for Property Management Agent"

  tags = merge(
    var.tags,
    {
      Name        = "prop-agent-${var.environment}-mongodb-uri"
      Environment = var.environment
    }
  )
}

resource "aws_secretsmanager_secret_version" "mongodb_uri" {
  secret_id = aws_secretsmanager_secret.mongodb_uri.id
  secret_string = jsonencode({
    mongodb_uri = var.mongodb_uri
  })
}

# Okta OIDC Configuration Secret
resource "aws_secretsmanager_secret" "okta_config" {
  name        = "prop-agent-${var.environment}-okta-config"
  description = "Okta OIDC client credentials and issuer URL"

  tags = merge(
    var.tags,
    {
      Name        = "prop-agent-${var.environment}-okta-config"
      Environment = var.environment
    }
  )
}

resource "aws_secretsmanager_secret_version" "okta_config" {
  secret_id = aws_secretsmanager_secret.okta_config.id
  secret_string = jsonencode({
    client_id  = var.okta_client_id
    issuer_url = var.okta_issuer_url
  })
}

# Salesforce OAuth Credentials Secret
resource "aws_secretsmanager_secret" "salesforce_creds" {
  name        = "prop-agent-${var.environment}-salesforce-creds"
  description = "Salesforce OAuth client credentials"

  tags = merge(
    var.tags,
    {
      Name        = "prop-agent-${var.environment}-salesforce-creds"
      Environment = var.environment
    }
  )
}

resource "aws_secretsmanager_secret_version" "salesforce_creds" {
  secret_id = aws_secretsmanager_secret.salesforce_creds.id
  secret_string = jsonencode({
    client_id     = var.salesforce_client_id
    client_secret = var.salesforce_client_secret
  })
}

# IAM Policy for EKS IRSA Service Accounts to read secrets
resource "aws_iam_policy" "secrets_read" {
  name        = "prop-agent-${var.environment}-secrets-read-policy"
  description = "Policy allowing EKS Fargate service accounts to read Secrets Manager secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          aws_secretsmanager_secret.mongodb_uri.arn,
          aws_secretsmanager_secret.okta_config.arn,
          aws_secretsmanager_secret.salesforce_creds.arn
        ]
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
