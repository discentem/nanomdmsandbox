locals {
  create_db_instance     = var.create_db_instance
  create_random_password = local.create_db_instance && var.create_random_password
  password               = local.create_random_password ? random_password.master_password[0].result : var.password
}

resource "random_password" "master_password" {
  count = local.create_random_password ? 1 : 0

  length  = var.random_password_length
  special = false
}

module "rds_mysql" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = "${var.app_name}-rds"

  engine            = "mysql"
# 8.0.19 minimum required version for current sql syntax
  engine_version    = "8.0.19"
  instance_class    = "db.t3.micro"
  allocated_storage = 10

  username = "root"
  password = local.password
  port     = "3306"

  publicly_accessible = false

  create_random_password = var.create_random_password
  create_db_instance = local.create_db_instance

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  skip_final_snapshot  = true

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval = "30"
  monitoring_role_name = "${var.app_name}-rds-monitoring-role"
  create_monitoring_role = true

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = var.database_subnets

  # DB parameter group
  family               = "mysql8.0" # DB parameter group

  # DB option group
  major_engine_version = "8.0"      # DB option group

  # Database Deletion Protection
  deletion_protection = false

  parameters = [
    {
      name = "character_set_client"
      value = "utf8mb4"
    },
    {
      name = "character_set_server"
      value = "utf8mb4"
    }
  ]

  # options = [
  #   {
  #     option_name = "MARIADB_AUDIT_PLUGIN"

  #     option_settings = [
  #       {
  #         name  = "SERVER_AUDIT_EVENTS"
  #         value = "CONNECT"
  #       },
  #       {
  #         name  = "SERVER_AUDIT_FILE_ROTATIONS"
  #         value = "37"
  #       },
  #     ]
  #   },
  # ]
}
