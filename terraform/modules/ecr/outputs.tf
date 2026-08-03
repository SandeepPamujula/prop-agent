output "repository_urls" {
  value       = { for repo in aws_ecr_repository.services : repo.name => repo.repository_url }
  description = "Map of ECR repository names to repository URLs"
}

output "repository_arns" {
  value       = { for repo in aws_ecr_repository.services : repo.name => repo.arn }
  description = "Map of ECR repository names to repository ARNs"
}
