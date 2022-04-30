# tf modules
# - create ecr registry
# - build container
# - publish to ecr

##############################
# - create fargate_resource
# - route53 records
# 

module "nanomdm_ecr" {
  source               = "./modules/ecr"
  repository_name      = var.repository_name
  image_tag_mutability = var.image_tag_mutability
}

module "route53" {
  source      = "./modules/route53"
  domain_name = var.domain_name
}

module "vpc" {

}

module "alb" {

}

module "ecs" {
  alb_arn = alb.arn
  ecr_arn = nanmodm_ecr.repository_arn
}