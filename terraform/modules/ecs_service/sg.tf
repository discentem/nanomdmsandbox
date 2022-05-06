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

  ingress {
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["73.202.235.154/32","73.241.146.111/32","8.18.221.137/32"]
    # ipv6_cidr_blocks  = ["::/0"]
  }


  ingress {
    from_port         = var.nanomdm_app_port
    to_port           = var.nanomdm_app_port
    protocol          = "tcp"
    cidr_blocks       = ["73.202.235.154/32","73.241.146.111/32","8.18.221.137/32"]
    # ipv6_cidr_blocks  = ["::/0"]
  }

  ingress {
    from_port         = var.scep_app_port
    to_port           = var.scep_app_port
    protocol          = "tcp"
    cidr_blocks       = ["73.202.235.154/32","73.241.146.111/32","8.18.221.137/32"]
    # ipv6_cidr_blocks  = ["::/0"]
  }



  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }


  revoke_rules_on_delete = true

  lifecycle {
    create_before_destroy = true
  }
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

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "nanomdm_ingress_ecs_service" {
  security_group_id = aws_security_group.ecs_service.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = var.nanomdm_app_port
  to_port           = var.nanomdm_app_port
  source_security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "scep_ingress_ecs_service" {
  security_group_id = aws_security_group.ecs_service.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = var.scep_app_port
  to_port           = var.scep_app_port
  source_security_group_id = aws_security_group.lb.id
}
