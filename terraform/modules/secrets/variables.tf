variable "name" {
  description = "Name for secrets manager resources."
  type        = string
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}
