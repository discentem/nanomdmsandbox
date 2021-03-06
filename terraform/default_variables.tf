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

// SCEP //
variable "scep_repository_name" {
  type        = string
  description = "SCEP ECR Repository Name"
  default = "scep"
}

// NanoMDM //
variable "nanomdm_repository_name" {
  type        = string
  description = "NanoMDM ECR Repository Name"
  default = "nanomdm"
}

// Micro2Nano //
variable "micro2nano_repository_name" {
  type = string
  description = "Micro2nano ECR Repository Name"
  default = "micro2nano"
}

// MDMDirector //
variable "mdmdirector_repository_name" {
  type = string
  description = "MDMDirector ECR Repository Name"
  default = "mdmdirector"
}

// Enroll Endpoint //
variable "enroll_endpoint_repository_name" {
  type = string
  description = "Enroll Endpoint ECR Repository Name"
  default = "enroll_endpoint"
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

variable "public_subnets" {
  type = list(string)
  description = "Public Subnet CIDR"
}

variable "private_subnets" {
  type = list(string)
  description = "Private Subnet CIDR"
}

variable "database_subnets" {
  type = list(string)
  description = "Database Subnet CIDR"
}

variable "enable_ipv6" {
  type = bool
  description = "Enable the usage of IPv6"
  default = true
}

variable "enable_nat_gateway" {
  type = bool
  description = "Enable the usage of a NAT gateway"
  default = true
}

variable "create_database_subnet_group" {
  type = bool
  description = "Enable the creation of the database subnet group"
  default = true
}

variable "availability_zones" {
  type = list(string)
  description = "VPC AZs"
}

variable "public_inbound_cidr_blocks_ipv4" {
  type = list(string)
  description = "list of allowed CIDRs to reach public resources"
  # default = ["0.0.0.0/0"]
}

variable "public_inbound_cidr_blocks_ipv6" {
  type = list(string)
  description = "list of allowed CIDRs to reach public resources"
  # default = ["::/0"]
}

variable "public_key" {
  type = string
  description = "ec2 key pair public key material"
  sensitive = true
  default = ""
}

# variable "enrollment_profile_object_name" {
#   description = "Key in s3 referencing the enrollment.mobileconfig"
#   type        = string
#   default = "enrollment.mobileconfig"
# }

# variable "enrollment_profile_source_path" {
#   description = "Local source for enrollment.mobileconfig"
#   type        = string
#   default = "../app/enrollment.mobileconfig"
# }


# variable "AWS_ACCESS_KEY" {}
# variable "AWS_SECRET_KEY" {}
