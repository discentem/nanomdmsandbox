variable "app_name" {
  description = "The application/service name used with the prefix for naming resources."
  type        = string
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "database_subnets" {
  description = "A list of subnets of allowed subnets that RDS will be deployed within"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "A list of subnets of allowed subnets that can reach the RDS instances"
  type        = list(string)
}
