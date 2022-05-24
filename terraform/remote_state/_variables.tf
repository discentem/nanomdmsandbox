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
