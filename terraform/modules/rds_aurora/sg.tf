module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.9.0"

  name        = "${var.app_name}-rds-psql"
  description = "${var.app_name}-rds-psql security group"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks      = var.allowed_cidr_blocks
  ingress_rules            = ["postgresql-tcp"]
}
