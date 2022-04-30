resource "aws_vpc" "main" {
  cidr_block       =  "172.2.0.0/16"
  instance_tenancy = "default"
}