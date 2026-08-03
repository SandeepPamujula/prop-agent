module "networking" {
  source = "../../modules/networking"

  environment          = var.environment
  aws_region           = var.aws_region
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "compute_eks" {
  source = "../../modules/compute-eks"

  environment        = var.environment
  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
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
