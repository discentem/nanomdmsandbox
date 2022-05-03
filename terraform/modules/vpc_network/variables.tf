variable "aws_region" {
  type = string
  description = "AWS region"
  default = "us-east-1"
}

variable "availability_zones" {
  type        = list(any)
  description = "The names of the availability zones to use"
}

variable "vpc_cidr" {
    type = string
    description = "CIDR Block for the new VPC"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
}

variable "prefix" {
   description = "Prefix used for all resources names"
   default = ""
}
