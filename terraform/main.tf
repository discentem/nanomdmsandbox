# tf modules
# - create ecr registry
# - build container
# - publish to ecr

##############################
# - create fargate_resource
# - route53 records
#

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "nanomdm_ecr" {
  source               = "./modules/ecr"
  repository_name      = var.nanomdm_repository_name
  image_tag_mutability = var.image_tag_mutability
}

module "scep_ecr" {
  source               = "./modules/ecr"
  repository_name      = var.scep_repository_name
  image_tag_mutability = var.image_tag_mutability
}

module "micro2nano_ecr" {
  source               = "./modules/ecr"
  repository_name      = var.micro2nano_repository_name
  image_tag_mutability = var.image_tag_mutability
}

module "mdmdirector_ecr" {
  source               = "./modules/ecr"
  repository_name      = var.mdmdirector_repository_name
  image_tag_mutability = var.image_tag_mutability
}

module "enroll_endpoint_ecr" {
  source               = "./modules/ecr"
  repository_name      = var.enroll_endpoint_repository_name
  image_tag_mutability = var.image_tag_mutability
}

module "route53" {
  source      = "./modules/route53"
  domain_name = var.domain_name
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = var.app_name
  
  cidr = var.vpc_cidr

  azs              = var.availability_zones
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

  create_database_subnet_group = var.create_database_subnet_group

  enable_ipv6 = var.enable_ipv6

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "ecs_cluster" {
  source = "./modules/ecs_cluster"

  prefix   = var.prefix
  app_name = var.app_name
}

resource "random_password" "psql_rds_master_password" {
  length  = "20"
  special = false
}

module "rds_aurora_psql_mdmdirector" {
  source = "./modules/rds_aurora"

  app_name = var.app_name
  database_name = "mdmdirector"

  aws_region          = var.aws_region
  vpc_id              = module.vpc.vpc_id
  database_subnets    = module.vpc.database_subnets
  allowed_cidr_blocks = module.vpc.private_subnets_cidr_blocks

  create_random_password = false
  master_password = random_password.psql_rds_master_password.result
}

module "rds_aurora_psql_mdmdirector_secret" {
  source = "./modules/secrets"

  name   = "rds_aurora_psql_mdmdirector"

  aws_region           = var.aws_region
  aws_account_id       = data.aws_caller_identity.current.account_id
  
  secret_string        = jsonencode(
  { 
    PSQL_USERNAME = module.rds_aurora_psql_mdmdirector.cluster_master_username,
    PSQL_PASSWORD = module.rds_aurora_psql_mdmdirector.cluster_master_password,
    PSQL_HOSTNAME = module.rds_aurora_psql_mdmdirector.cluster_endpoint,
  })
}

resource "random_password" "scep_challenge" {
  length  = "20"
  special = false
}

module "scep_secrets" {
  source = "./modules/secrets"

  name   = "scep_secrets"

  aws_region           = var.aws_region
  aws_account_id       = data.aws_caller_identity.current.account_id
  
  secret_string        = jsonencode(
  { 
    SCEP_CHALLENGE = random_password.scep_challenge.result,
  })
}

resource "random_password" "nanomdm_api_key" {
  length  = "20"
  special = false
}

module "nanomdm_secrets" {
  source = "./modules/secrets"

  name   = "nanomdm_secrets"

  aws_region           = var.aws_region
  aws_account_id       = data.aws_caller_identity.current.account_id
  
  secret_string        = jsonencode(
  { 
    API_KEY = random_password.nanomdm_api_key.result,
  })
}


resource "random_password" "micro2nano_micromdm_api_key" {
  length  = "20"
  special = false
}

module "micro2nano_secrets" {
  source = "./modules/secrets"

  name   = "micro2nano_secrets"

  aws_region           = var.aws_region
  aws_account_id       = data.aws_caller_identity.current.account_id
  
  secret_string        = jsonencode(
  { 
    MICROMDM_API_KEY = random_password.micro2nano_micromdm_api_key.result,
  })
}

resource "random_password" "mdmdirector_api_key" {
  length  = "20"
  special = false
}

module "mdmdirector_secrets" {
  source = "./modules/secrets"

  name   = "mdmdirector_secrets"

  aws_region           = var.aws_region
  aws_account_id       = data.aws_caller_identity.current.account_id
  
  secret_string        = jsonencode(
  { 
    MDMDIRECTOR_API_KEY = random_password.mdmdirector_api_key.result,
  })
}

module "rds" {
  source = "./modules/rds"

  app_name = var.app_name
  db_name = "nanomdm"

  aws_region          = var.aws_region
  vpc_id              = module.vpc.vpc_id
  database_subnets    = module.vpc.database_subnets
  allowed_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  
  create_db_instance  = true

  create_random_password = false
  password = random_password.mysql_rds_master_password.result
}

resource "random_password" "mysql_rds_master_password" {
  length  = "20"
  special = false
}

module "ec2" {
  source = "./modules/ec2"

  app_name = var.app_name
  name = "ec2"
  key_name = aws_key_pair.key_pair.key_name
  ami = "ami-0022f774911c1d690"
  instance_type = "t2.micro"
  vpc_security_group_ids = [module.ec2_security_group.security_group_id]
  subnet_id = module.vpc.public_subnets[0]
  associate_public_ip_address = true
}

module "ec2_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.9.0"

  name        = "${var.app_name}-ec2"
  description = "${var.app_name}-ec2 security group"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = var.public_inbound_cidr_blocks_ipv4
  ingress_rules            = ["ssh-tcp"]

  egress_with_cidr_blocks = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = "0.0.0.0/0"
    },
  ]
}

resource "aws_key_pair" "key_pair" {
  key_name   = "ec2_key_pair"
  public_key = "${var.public_key == "" ? file("~/.ssh/ec2.pub") : var.public_key}"
}
module "rds_secret" {
  source = "./modules/secrets"

  name   = "rds"

  aws_region           = var.aws_region
  aws_account_id       = data.aws_caller_identity.current.account_id
  
  secret_string        = jsonencode(
  { 
    MYSQL_USERNAME = module.rds.db_instance_username,
    MYSQL_PASSWORD = module.rds.db_instance_password,
    MYSQL_HOSTNAME = module.rds.db_instance_address,
    MYSQL_DSN      = "${module.rds.db_instance_username}:${random_password.mysql_rds_master_password.result}@tcp(${module.rds.db_instance_endpoint})/nanomdm"
  }
  )
  # secret_string        = jsonencode({ MYSQL_USERNAME = module.rds.mysql_cluster_master_username, MYSQL_PASSWORD = module.rds.mysql_cluster_master_password})
}
module "acm_lb_certificate" {
  source = "./modules/acm"
  domain_name = "mdm-infra.${var.domain_name}"
  zone_id     = module.route53.zone_id
}

module "ecs_nanomdm" {
  source = "./modules/ecs_service"

  prefix   = var.prefix
  app_name = var.app_name

  vpc_id = module.vpc.vpc_id

  cluster_id = module.ecs_cluster.cluster_id

  private_subnet_ids = module.vpc.private_subnets
  public_subnet_ids  = module.vpc.public_subnets

  lb_subdomain_name = "mdm-infra"
  domain_name = var.domain_name
  zone_id     = module.route53.zone_id
  certificate_arn = module.acm_lb_certificate.acm_certificate_arn

  container_definition_cpu = 1024
  container_definition_memory = 2048

  // SCEP tasks //
  scep_container_image = "${module.scep_ecr.repository_url}:latest"
  scep_app_port        = 8080

  # scep_task_mount_points = { sourceVolume = string, containerPath = string, readOnly = bool }
  scep_task_definition_cpu    = 128
  scep_task_definition_memory = 256

  scep_health_check = {
    port                = "traffic-port"
    path                = "/scep?operation=GetCACert"
    health_threshold    = "3"
    interval            = "60"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    unhealthy_threshold = "2"
  }

  scep_secrets_manager_arn = module.scep_secrets.arn

  // NanoMDM tasks //
  nanomdm_container_image = "${module.nanomdm_ecr.repository_url}:latest"
  nanomdm_app_port        = 9000

  mysql_secrets_manager_arn = module.rds_secret.arn
  nanomdm_task_container_environment = {
    APP_NAME       = var.app_name
  }

  # nanomdm_task_mount_points = { sourceVolume = string, containerPath = string, readOnly = bool }
  nanomdm_task_definition_cpu    = 128
  nanomdm_task_definition_memory = 256
  nanomdm_health_check = {
    port                = "traffic-port"
    path                = "/version"
    health_threshold    = "3"
    interval            = "60"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    unhealthy_threshold = "2"
  }

  nanomdm_secrets_manager_arn = module.nanomdm_secrets.arn

  // MDMDirector tasks //
  mdmdirector_container_image = "${module.mdmdirector_ecr.repository_url}:latest"
  mdmdirector_app_port        = 8000

  psql_secrets_manager_arn = module.rds_aurora_psql_mdmdirector_secret.arn
  mdmdirector_task_container_environment = {
    APP_NAME       = var.app_name
  }

  mdmdirector_task_definition_cpu    = 128
  mdmdirector_task_definition_memory = 256
  mdmdirector_health_check = {
    port                = "traffic-port"
    path                = "/health"
    health_threshold    = "3"
    interval            = "60"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    unhealthy_threshold = "2"
  }

  mdmdirector_secrets_manager_arn = module.mdmdirector_secrets.arn

  // micro2nano tasks //
  micro2nano_container_image = "${module.micro2nano_ecr.repository_url}:latest"
  micro2nano_app_port        = 9001
  micro2nano_task_container_environment = {
    NANO_URL       = "http://127.0.0.1:9000/v1/enqueue",
  }

  micro2nano_task_definition_cpu    = 128
  micro2nano_task_definition_memory = 256

  # micro2nano_health_check = {
  #   port                = "traffic-port"
  #   path                = "/v1/commands"
  #   health_threshold    = "3"
  #   interval            = "60"
  #   protocol            = "HTTP"
  #   matcher             = "401"
  #   timeout             = "3"
  #   unhealthy_threshold = "2"
  # }

  micro2nano_secrets_manager_arn = module.micro2nano_secrets.arn

  // Enroll Endpoint tasks //
  enroll_endpoint_container_image = "${module.enroll_endpoint_ecr.repository_url}:latest"
  enroll_endpoint_app_port        = 9300

  enroll_endpoint_task_definition_cpu    = 128
  enroll_endpoint_task_definition_memory = 256

  enroll_endpoint_health_check = {
    port                = "traffic-port"
    path                = "/health"
    health_threshold    = "3"
    interval            = "60"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    unhealthy_threshold = "2"
  }

  enroll_endpoint_task_container_environment = {
    APP_NAME       = var.app_name,
    COMPANY        = "corporation",
    BASE_URL       = "https://mdm-infra.${var.domain_name}"
  }

  // Public CIDRs to allow access to the load balancers //
  public_inbound_cidr_blocks_ipv4 = var.public_inbound_cidr_blocks_ipv4
  public_inbound_cidr_blocks_ipv6 = var.public_inbound_cidr_blocks_ipv6
}

# module "push_docker_images" {
#   source     = "./modules/push_images"
#   depends_on = [module.nanomdm_ecr.repository_url, module.scep_ecr.repository_url]
# }

# module "enrollment_profile" {
#   source = "./modules/s3"
#   bucket_name = var.domain_name
#   enrollment_profile_source_path = var.enrollment_profile_source_path
# }
