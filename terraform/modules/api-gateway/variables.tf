variable "environment" {
  type        = string
  description = "Environment name (e.g. dev, staging, prod)"
  default     = "dev"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where ALB will be deployed"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for ALB placement"
}

variable "target_port" {
  type        = number
  description = "Port on which EKS Fargate Orchestrator pods listen"
  default     = 8080
}

variable "acm_certificate_arn" {
  type        = string
  description = "Optional existing ACM Certificate ARN. If empty, a self-signed TLS certificate will be generated."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
