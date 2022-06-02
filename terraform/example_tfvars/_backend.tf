terraform {
  required_version = ">= 1.1.9"
  backend "s3" {
    bucket = ""
    key    = "global/s3/production-nanomdm-terraform.tfstate"
    region = "us-east-1"
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
      App_Name = "nanomdm"
    }
  }
}
