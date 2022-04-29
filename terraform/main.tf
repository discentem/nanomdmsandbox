# tf modules
# - create ecr registry
# - build container
# - publish to ecr

##############################
# - create fargate_resource
# - route53 records
# 

# module "nanomdm_ecr" {
#   source               = "./modules/ecr"
#   repository_name      = "nanomdm"
#   image_tag_mutability = "MUTABLE"
# }

terraform {
  required_version = ">= 1.1.9"
  backend "local" {
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.12.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Name = "nanomdm"
    }
  }
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}

module "route53" {
  source      = "./nanomdm/modules/route53"
  domain_name = var.domain_name
  ttl         = var.ttl
}

# module "fargate" {
#   ecr_arn = nanmodm_ecr.repository_arn
# }