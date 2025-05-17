terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.4" #avoid 6 for now, it just released as a beta a week ago
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "us-east-1"
}

module "iam" {
  source       = "./iam"
  suffix       = random_id.suffix.hex
  default_tags = local.default_tags
}

module "compute" {
  source                 = "./compute"
  default_tags           = local.default_tags
  user_saves_bucket_name = module.storage.user_saves_bucket_name
  lambda_exec_role_arn   = module.iam.lambda_exec_role_arn
  environment = local.Environment
  api_auto_deploy  = var.api_auto_deploy
}

module "storage" {
  source       = "./storage"
  suffix       = random_id.suffix.hex
  default_tags = local.default_tags
  api_base_url = module.compute.api_gateway_endpoint
  environment = local.Environment
}