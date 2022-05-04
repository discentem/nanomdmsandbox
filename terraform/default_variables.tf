variable "aws_region" {
  type = string
  description = "AWS region"
  default = "us-east-1"
}
variable "prefix" {
  type = string
  description = "Prefix for environment"
  default = "production"
}

variable "app_name" {
  type = string
  description = "Application name"
  default = "nanomdm"
}

variable "scep_repository_name" {
  type        = string
  description = "SCEP ECR Repository Name"
  default = "scep"
}

variable "nanomdm_repository_name" {
  type        = string
  description = "NanoMDM ECR Repository Name"
  default = "nanomdm"
}

variable "image_tag_mutability" {
  type        = string
  description = "Image tag mutability of: [MUTABLE, IMMUTABLE]. Defaults to MUTABLE."
  default     = "MUTABLE"
}

variable "domain_name" {
    type = string
    description = "Domain name for the primary Route53 zone record"
}

variable "vpc_cidr" {
  type = string
  description = "VPC CIDR Block"
}

variable "public_subnets_cidr" {
  type = list
  description = "Public Subnet CIDR"
}

variable "private_subnets_cidr" {
  type = list
  description = "Private Subnet CIDR"
}

variable "availability_zones" {
  type = list
  description = "VPC AZs"
}

variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
