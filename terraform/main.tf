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

module "vpc_network" {
  source = "./modules/vpc_network"

  aws_region           = var.aws_region
  availability_zones   = var.availability_zones
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
}

#   certificate_arn   = module.acm.acm_certificate_arn
#   subnet_ids         = module.vpc_network.private_subnets_id
#   vpc_id            = module.vpc_network.id
#   aws_region        = var.aws_region
#   zone_id           = module.route53.zone_id

module "ecs_cluster" {
  source = "./modules/ecs_cluster"

  prefix        = var.prefix
  app_name      = var.app_name
}


module "rds_secret" {
  source = "./modules/secret"

  name   = "rds"

  aws_region           = var.aws_region
  account_id           = data.aws_caller_identity.current.account_id

}


module "ecs_nanomdm" {
  source = "./modules/ecs_service"

  prefix        = var.prefix
  app_name      = var.app_name

  vpc_id        = module.vpc_network.id

  cluster_id    = module.ecs_cluster.cluster_id

  private_subnet_ids = module.vpc_network.private_subnets_ids
  public_subnet_ids = module.vpc_network.public_subnets_ids

  scep_container_image = "${module.scep_ecr.repository_url}/scep:latest"
  scep_app_port = 8080

  # scep_task_mount_points = { sourceVolume = string, containerPath = string, readOnly = bool }
  scep_task_definition_cpu = 256
  scep_task_definition_memory = 512

  scep_health_check = {
    port = "traffic-port"
    path = "/"
    health_threshold = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    unhealthy_threshold = "2"
  }

  nanomdm_container_image = "${module.nanomdm_ecr.repository_url}/nanomdm:latest"
  nanomdm_app_port = 9000
  
  # nanomdm_task_mount_points = { sourceVolume = string, containerPath = string, readOnly = bool }
  nanomdm_task_definition_cpu = 256
  nanomdm_task_definition_memory = 512
  nanomdm_health_check = {
    port = "traffic-port"
    path = "/"
    health_threshold = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    unhealthy_threshold = "2"
  }

  depends_on = [module.push_docker_images]

}

module "push_docker_images" {
  source               = "./modules/push_images"
  depends_on = [module.nanomdm_ecr.repository_url, module.scep_ecr.repository_url]
}
