module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.9.0"

  name        = "${var.app_name}-rds"
  description = "${var.app_name}-rds security group"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks      = var.allowed_cidr_blocks
  ingress_rules            = ["mysql-tcp"]

#   egress_with_cidr_blocks = [
#     {
#       from_port         = 0
#       to_port           = 0
#       protocol          = "-1"
#       cidr_blocks = "0.0.0.0/0"
#     }
#   ]

#   computed_ingress_with_source_security_group_id = [
#     {
#       rule                     = "mysql-tcp"
#       source_security_group_id = var.ecs_service_security_group_id
#     }
#   ]

#   number_of_computed_ingress_with_source_security_group_id = 1

  # ingress
#   ingress_with_cidr_blocks = [
#     {
#       from_port   = 3306
#       to_port     = 3306
#       protocol    = "tcp"
#       description = "MySQL access from within VPC"
#       cidr_blocks = var.allowed_cidr_blocks
#     }
#   ]
}

# resource "aws_security_group_rule" "s3_gateway_egress" {
#   description       = "S3 Gateway Egress"
#   type              = "egress"
#   security_group_id = aws_security_group.rds.id
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   source_security_group_id = 
# }