output "cluster_name" {
  value       = aws_eks_cluster.main.name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "Endpoint for EKS control plane"
}

output "cluster_certificate_authority_data" {
  value       = aws_eks_cluster.main.certificate_authority[0].data
  description = "Base64 encoded certificate data required to communicate with the cluster"
}

output "oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.eks.arn
  description = "ARN of the OIDC provider for IRSA"
}

output "oidc_provider_url" {
  value       = aws_iam_openid_connect_provider.eks.url
  description = "URL of the OIDC provider for IRSA"
}

output "model_gateway_role_arn" {
  value       = aws_iam_role.model_gateway_irsa.arn
  description = "IAM Role ARN for Model Gateway service account"
}

output "orchestrator_role_arn" {
  value       = aws_iam_role.orchestrator_irsa.arn
  description = "IAM Role ARN for Orchestrator service account"
}
