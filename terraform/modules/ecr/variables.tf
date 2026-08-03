variable "environment" {
  type        = string
  description = "Environment name (e.g. dev, staging, prod)"
  default     = "dev"
}

variable "repository_names" {
  type        = list(string)
  description = "List of ECR repository names to create"
  default     = ["orchestrator", "model-gateway", "mcp-server"]
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
