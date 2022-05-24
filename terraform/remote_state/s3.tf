terraform {
  required_version = ">= 1.1.9"
  backend "local" {}
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.prefix}-${var.app_name}-terraform-state"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse_configuration" {
  bucket = aws_s3_bucket.terraform_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
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