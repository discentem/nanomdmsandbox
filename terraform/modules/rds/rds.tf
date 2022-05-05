module "aurora_mysql" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "7.1.0"

  name              = "${var.app_name}-rds-aurora-mysql"
  engine            = "aurora-mysql"
  engine_mode       = "serverless"
  storage_encrypted = true

  subnets               = var.database_subnets
  create_security_group = true

  monitoring_interval = 60

  apply_immediately   = true
  skip_final_snapshot = true

  vpc_id                 = var.vpc_id
  allowed_cidr_blocks    = var.allowed_cidr_blocks
  # allowed_security_groups = var.allowed_security_groups

  create_random_password = true

  security_group_use_name_prefix = false
  db_parameter_group_name         = aws_db_parameter_group.mysql.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.mysql.id
  # enabled_cloudwatch_logs_exports = # NOT SUPPORTED

  scaling_configuration = {
    auto_pause               = true
    min_capacity             = 2
    max_capacity             = 16
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }
}

resource "aws_db_parameter_group" "mysql" {
  name        = "${var.app_name}-aurora-db-mysql-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${var.app_name}-aurora-db-mysql-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "mysql" {
  name        = "${var.app_name}-aurora-mysql-cluster-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${var.app_name}-aurora-mysql-cluster-parameter-group"
}

# resource "aws_security_group" "rds" {
#   vpc_id      = var.vpc_id
#   name        = "${local.prefix_app_name}-rds"
#   description = "${local.prefix_app_name}-rds security group"
#   tags = merge(
#     var.tags,
#     {
#       Name = "${local.prefix_app_name}-rds-sg"
#     },
#   )

#   ingress {
#     description = "MySQL Database Ingress"
#     from_port   = 5432
#     to_port     = 5432
#     protocol    = "tcp"
#     cidr_blocks = var.subnets
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   revoke_rules_on_delete = true

#   lifecycle {
#     create_before_destroy = true
#   }
# }
