locals {
  create_random_password = var.create_random_password
  master_password        = local.create_random_password ? random_password.master_password[0].result : var.master_password
}

resource "random_password" "master_password" {
  count = local.create_random_password ? 1 : 0

  length  = var.random_password_length
  special = false
}


data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  # version = "12.8"
  version = "13.6"
}

module "aurora_postgresql_serverless_v2" {
  source            = "terraform-aws-modules/rds-aurora/aws"
  version           = "7.1.0"
  name              = "${var.app_name}-postgresqlv2"
  engine            = data.aws_rds_engine_version.postgresql.engine
  engine_mode       = "provisioned"
  engine_version    = data.aws_rds_engine_version.postgresql.version
  storage_encrypted = true

  vpc_id                = var.vpc_id
  subnets               = var.database_subnets
  create_security_group = false

  allowed_cidr_blocks   = var.allowed_cidr_blocks

  create_random_password = local.create_random_password
  master_password = local.master_password

  # iam_database_authentication_enabled = true

  database_name = var.database_name

  monitoring_interval = 60

  apply_immediately   = true
  skip_final_snapshot = true

  vpc_security_group_ids = [module.security_group.security_group_id]

  db_parameter_group_name         = aws_db_parameter_group.postgresql_parameter_group.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.postgresql_cluster_parameter_group.id

  serverlessv2_scaling_configuration = {
    min_capacity = 0.5
    max_capacity = 1.0
  }

  instance_class = "db.serverless"
  instances = {
    one = {}
    two = {}
  }
}

resource "aws_db_parameter_group" "postgresql_parameter_group" {
  name        = "${var.app_name}-aurora-db-postgres13-parameter-group"
  family      = "aurora-postgresql13"
  description = "${var.app_name}-aurora-db-postgres13-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "postgresql_cluster_parameter_group" {
  name        = "${var.app_name}-aurora-postgres13-cluster-parameter-group"
  family      = "aurora-postgresql13"
  description = "${var.app_name}-aurora-postgres13-cluster-parameter-group"
}
