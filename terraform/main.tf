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
  # cidr = "10.99.0.0/18"

  # azs              = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  # public_subnets   = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  # private_subnets  = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
  # database_subnets = ["10.99.7.0/24", "10.99.8.0/24", "10.99.9.0/24"]
  
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

# module "rds_auora" {
#   source = "./modules/rds_aurora"

#   app_name = var.app_name

#   aws_region          = var.aws_region
#   vpc_id              = module.vpc.vpc_id
#   database_subnets    = module.vpc.database_subnets
#   allowed_cidr_blocks = module.vpc.private_subnets_cidr_blocks
# }

module "rds" {
  source = "./modules/rds"

  app_name = var.app_name

  aws_region          = var.aws_region
  vpc_id              = module.vpc.vpc_id
  database_subnets    = module.vpc.database_subnets
  allowed_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  
  create_db_instance  = true

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

  container_definition_cpu = 512
  container_definition_memory = 1024

  // SCEP TASKs //

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

  // NanoMDM TASKs //

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

  // Public CIDRs to allow access to the load balancers //

  public_inbound_cidr_blocks_ipv4 = var.public_inbound_cidr_blocks_ipv4
  public_inbound_cidr_blocks_ipv6 = var.public_inbound_cidr_blocks_ipv6

  # depends_on = [module.push_docker_images]

}

# module "push_docker_images" {
#   source     = "./modules/push_images"
#   depends_on = [module.nanomdm_ecr.repository_url, module.scep_ecr.repository_url]
# }
