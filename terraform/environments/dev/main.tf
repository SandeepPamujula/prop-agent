module "networking" {
  source = "../../modules/networking"

  environment          = var.environment
  aws_region           = var.aws_region
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "secrets" {
  source = "../../modules/secrets"

  environment = var.environment
}

module "ecr" {
  source = "../../modules/ecr"

  environment      = var.environment
  repository_names = ["orchestrator", "model-gateway", "mcp-server"]
}

module "compute_eks" {
  source = "../../modules/compute-eks"

  environment             = var.environment
  cluster_name            = var.cluster_name
  cluster_version         = var.cluster_version
  vpc_id                  = module.networking.vpc_id
  private_subnet_ids      = module.networking.private_subnet_ids
  secrets_read_policy_arn = module.secrets.secrets_read_policy_arn
}

module "api_gateway" {
  source = "../../modules/api-gateway"

  environment         = var.environment
  vpc_id              = module.networking.vpc_id
  public_subnet_ids   = module.networking.public_subnet_ids
  acm_certificate_arn = var.acm_certificate_arn
  target_port         = 8080
}

output "vpc_id" {
  value = module.networking.vpc_id
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "eks_cluster_name" {
  value = module.compute_eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.compute_eks.cluster_endpoint
}

output "alb_dns_name" {
  value = module.api_gateway.alb_dns_name
}

output "mongodb_secret_arn" {
  value = module.secrets.mongodb_secret_arn
}

output "okta_secret_arn" {
  value = module.secrets.okta_secret_arn
}

output "salesforce_secret_arn" {
  value = module.secrets.salesforce_secret_arn
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}
