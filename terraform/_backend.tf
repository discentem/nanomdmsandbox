terraform {
  required_version = ">= 1.1.9"
  backend "local" {}

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