variable "environment" {
  type        = string
  description = "Environment name (e.g. dev, staging, prod)"
  default     = "dev"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
  default     = "prop-agent-dev-eks"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes version for EKS"
  default     = "1.30"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where EKS will be deployed"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for EKS Fargate pods"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
