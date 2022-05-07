variable "name" {
  description = "Name for secrets manager resources."
  type        = string
}

variable "app_name" {
  type        = string
  description = ""
}

variable "key_name" {
  type        = string
  description = ""
}

variable "ami" {
  type        = string
  description = ""
}

variable "instance_type" {
    type = string
    description = ""
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = ""
}

variable "subnet_id" {
  type        = string
  description = ""
}
