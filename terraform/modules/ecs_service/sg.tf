resource "aws_security_group" "lb" {
  vpc_id      = var.vpc_id
  name        = "${local.prefix_app_name}-ecs-service-lb"
  description = "${local.prefix_app_name}-ecs service lb security group"
  tags = merge(
    var.tags,
    {
      Name = "${local.prefix_app_name}-ecs-service-lb-sg"
    },
  )

  revoke_rules_on_delete = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "egress_all_lb" {
  security_group_id = aws_security_group.lb.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}


resource "aws_security_group_rule" "nanomdm_ingress_lb" {
  security_group_id = aws_security_group.lb.id
  type              = "ingress"
  protocol          = "-1"
  from_port         = var.nanomdm_app_port
  to_port           = var.nanomdm_app_port
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "scep_ingress_lb" {
  security_group_id = aws_security_group.lb.id
  type              = "ingress"
  protocol          = "-1"
  from_port         = var.scep_app_port
  to_port           = var.scep_app_port
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}


resource "aws_security_group" "ecs_service" {
  vpc_id      = var.vpc_id
  name        = "${local.prefix_app_name}-ecs-service-sg"
  description = "${local.prefix_app_name}-fargate service security group"
  tags = merge(
    var.tags,
    {
      Name = "${local.prefix_app_name}-ecs-service-sg"
    },
  )

  revoke_rules_on_delete = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "nanomdm_ingress_ecs_service" {
  security_group_id = aws_security_group.ecs_service.id
  type              = "ingress"
  protocol          = "-1"
  from_port         = var.nanomdm_app_port
  to_port           = var.nanomdm_app_port
  source_security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "scep_ingress_ecs_service" {
  security_group_id = aws_security_group.ecs_service.id
  type              = "ingress"
  protocol          = "-1"
  from_port         = var.scep_app_port
  to_port           = var.scep_app_port
  source_security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "egress_all_ecs_service" {
  security_group_id = aws_security_group.ecs_service.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}