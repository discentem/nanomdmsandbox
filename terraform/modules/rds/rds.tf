module "aurora_mysql" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "6.0.0"

  name              = var.name
  engine            = "aurora-mysql"
  engine_mode       = "serverless"
  storage_encrypted = true

  vpc_id                 = var.vpc_id
  subnets                = var.subnets
  create_security_group  = false
  allowed_cidr_blocks    = var.subnet_cidr_block
  vpc_security_group_ids = var.security_group_ids

  create_random_password = false
  master_username        = var.username
  master_password        = var.password

  monitoring_interval = 60
  apply_immediately   = true
  skip_final_snapshot = true

  scaling_configuration = {
    auto_pause               = true
    min_capacity             = 2
    max_capacity             = 16
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }
}

resource "aws_security_group" "rds" {
  vpc_id      = var.vpc_id
  name        = "${local.prefix_app_name}-rds"
  description = "${local.prefix_app_name}-rds security group"
  tags = merge(
    var.tags,
    {
      Name = "${local.prefix_app_name}-rds-sg"
    },
  )

  ingress {
    description = "MySQL Database Ingress"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  revoke_rules_on_delete = true

  lifecycle {
    create_before_destroy = true
  }
}
