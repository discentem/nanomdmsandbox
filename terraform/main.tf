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

module "route53" {
  source      = "./modules/route53"
  domain_name = var.domain_name
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = var.app_name
  cidr = "10.99.0.0/18"

  azs              = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  public_subnets   = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  private_subnets  = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
  database_subnets = ["10.99.7.0/24", "10.99.8.0/24", "10.99.9.0/24"]

  enable_ipv6 = true

  enable_nat_gateway = true
  single_nat_gateway = true
}

module "ecs_cluster" {
  source = "./modules/ecs_cluster"

  prefix   = var.prefix
  app_name = var.app_name
}

module "rds" {
  source = "./modules/rds"

  app_name = var.app_name

  aws_region          = var.aws_region
  vpc_id              = module.vpc.vpc_id
  database_subnets    = module.vpc.database_subnets
  allowed_cidr_blocks = module.vpc.database_subnets_cidr_blocks
}

module "rds_secret" {
  source = "./modules/secrets"

  name   = "rds"

  aws_region           = var.aws_region
  aws_account_id       = data.aws_caller_identity.current.account_id

  secret_string        = jsonencode({ USERNAME = module.rds.mysql_cluster_master_username, PASSWORD = module.rds.mysql_cluster_master_password})
}

module "ecs_nanomdm" {
  source = "./modules/ecs_service"

  prefix   = var.prefix
  app_name = var.app_name

  vpc_id = module.vpc.vpc_id

  cluster_id = module.ecs_cluster.cluster_id

  private_subnet_ids = module.vpc.private_subnets
  public_subnet_ids  = module.vpc.public_subnets

  container_definition_cpu = 256
  container_definition_memory = 512

  scep_container_image = "${module.scep_ecr.repository_url}/scep:latest"
  scep_app_port        = 8080

  # scep_task_mount_points = { sourceVolume = string, containerPath = string, readOnly = bool }
  scep_task_definition_cpu    = 128
  scep_task_definition_memory = 256

  scep_health_check = {
    port                = "traffic-port"
    path                = "/"
    health_threshold    = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    unhealthy_threshold = "2"
  }

  nanomdm_container_image = "${module.nanomdm_ecr.repository_url}/nanomdm:latest"
  nanomdm_app_port        = 9000
  nanomdm_task_container_environment = {
    MYSQL_HOSTNAME = module.rds.mysql_cluster_master_username
    MYSQL_USERNAME = module.rds.mysql_cluster_endpoint
  }

  # nanomdm_task_mount_points = { sourceVolume = string, containerPath = string, readOnly = bool }
  nanomdm_task_definition_cpu    = 128
  nanomdm_task_definition_memory = 256
  nanomdm_health_check = {
    port                = "traffic-port"
    path                = "/"
    health_threshold    = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    unhealthy_threshold = "2"
  }

  depends_on = [module.push_docker_images]

}

module "push_docker_images" {
  source     = "./modules/push_images"
  depends_on = [module.nanomdm_ecr.repository_url, module.scep_ecr.repository_url]
}
