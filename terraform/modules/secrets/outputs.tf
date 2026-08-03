output "mongodb_secret_arn" {
  value       = aws_secretsmanager_secret.mongodb_uri.arn
  description = "ARN of the MongoDB connection URI secret"
}

output "okta_secret_arn" {
  value       = aws_secretsmanager_secret.okta_config.arn
  description = "ARN of the Okta OIDC configuration secret"
}

output "salesforce_secret_arn" {
  value       = aws_secretsmanager_secret.salesforce_creds.arn
  description = "ARN of the Salesforce OAuth credentials secret"
}

output "secrets_read_policy_arn" {
  value       = aws_iam_policy.secrets_read.arn
  description = "ARN of the IAM policy permitting reading of prop-agent secrets"
}
