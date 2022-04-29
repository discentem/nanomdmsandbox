variable "repository_name" {
  type        = string
  description = "ECR Repository Name"
  default = ""
}

variable "image_tag_mutability" {
  type        = string
  description = "Image tag mutability of: [MUTABLE, IMMUTABLE]. Defaults to MUTABLE."
  default     = "MUTABLE"
}

variable "domain_name" {
    type = string
    description = "Domain name for the primary Route53 zone record"
    default = "example.com"
}

variable "aws_region" {
  type = string
  description = "AWS region"
  default = "us-east-1"
}

variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
