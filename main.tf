terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "us-east-1"
}

module "storage" {
  source = "./storage"
  suffix = random_id.suffix.hex
  default_tags = local.default_tags
}

module "iam" {
  source = "./iam"
  suffix = random_id.suffix.hex
  default_tags = local.default_tags
}

module "compute" {
  source = "./compute"
  default_tags = local.default_tags
  user_saves_bucket_name  = module.storage.user_saves_bucket_name
  lambda_exec_role_arn    = module.iam.lambda_exec_role_arn
}



# add variables here if needed for any module inputs
