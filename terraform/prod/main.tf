provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../modules/vpc"

  project     = "devops-project"
  environment = "prod"

  vpc_cidr = "10.20.0.0/16"

  # 1 seule AZ pour PROD (non-HA, mais demandé ici)
  azs = ["us-east-1a"]

  # 1 subnet public /24
  public_subnet_cidrs = [
    "10.20.10.0/24"
  ]

  # 1 subnet privé /24
  private_subnet_cidrs = [
    "10.20.20.0/24"
  ]

  # Avec 1 AZ, ça reste logique: 1 NAT gateway.
  single_nat_gateway = true

  tags = {
    Owner = "team-devops"
  }
}

module "ecs" {
  source = "../modules/ecs"

  project     = "devops-project"
  environment = "prod"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  backend_image  = var.backend_image
  frontend_image = var.frontend_image
}

module "ecr_backend" {
  source = "../modules/ecr"
  name   = "brief3-backend"
  tags = {
    Project     = "devops-project"
    Environment = "dev"
  }
}

module "ecr_frontend" {
  source = "../modules/ecr"
  name   = "brief3-frontend"
  tags = {
    Project     = "devops-project"
    Environment = "dev"
  }
}
