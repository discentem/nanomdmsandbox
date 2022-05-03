variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "certificate_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "internal_alb" {
  type    = bool
  default = true
}

variable "prefix" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "zone_id" {
  type = string
}
