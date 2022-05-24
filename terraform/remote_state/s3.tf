terraform {
  required_version = ">= 1.1.9"
  backend "local" {}
}

resource "random_id" "rand_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.app_name}-terraform-state-${random_id.rand_id.hex}"
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