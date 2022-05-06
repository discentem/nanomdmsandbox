resource "aws_alb" "lb" {
  name            = local.prefix_app_name
  subnets         = var.public_subnet_ids
  load_balancer_type = "application"
  # certificate_arn = var.certificate_arn
  security_groups = [aws_security_group.lb.id]
}

resource "aws_route53_record" "this" {
  zone_id = var.zone_id
  name    = "${var.lb_subdomain_name}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_alb.lb.dns_name
    zone_id                = aws_alb.lb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_alb_target_group" "scep" {
  name        = "${local.prefix_app_name}-scep-tg"
  port        = var.scep_app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  # health_check {
  #   healthy_threshold   = "3"
  #   interval            = "30"
  #   protocol            = "HTTP"
  #   matcher             = "200"
  #   timeout             = "3"
  #   path                = var.health_check_path
  #   unhealthy_threshold = "2"
  # }

  dynamic "health_check" {
    for_each = [var.scep_health_check]
    content {
      enabled             = lookup(health_check.value, "enabled", null)
      interval            = lookup(health_check.value, "interval", null)
      path                = lookup(health_check.value, "path", null)
      port                = lookup(health_check.value, "port", null)
      protocol            = lookup(health_check.value, "protocol", null)
      timeout             = lookup(health_check.value, "timeout", null)
      healthy_threshold   = lookup(health_check.value, "healthy_threshold", null)
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", null)
      matcher             = lookup(health_check.value, "matcher", null)
    }
  }
}

resource "aws_alb_target_group" "nanomdm" {
  name        = "${local.prefix_app_name}-nanomdm-tg"
  port        = var.nanomdm_app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  dynamic "health_check" {
    for_each = [var.nanomdm_health_check]
    content {
      enabled             = lookup(health_check.value, "enabled", null)
      interval            = lookup(health_check.value, "interval", null)
      path                = lookup(health_check.value, "path", null)
      port                = lookup(health_check.value, "port", null)
      protocol            = lookup(health_check.value, "protocol", null)
      timeout             = lookup(health_check.value, "timeout", null)
      healthy_threshold   = lookup(health_check.value, "healthy_threshold", null)
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", null)
      matcher             = lookup(health_check.value, "matcher", null)
    }
  }
}

# resource "aws_lb_listener_rule" "static" {
#   listener_arn = aws_lb_listener.front_end.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.static.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/static/*"]
#     }
#   }

#   condition {
#     host_header {
#       values = ["example.com"]
#     }
#   }
# }

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.lb.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.nanomdm.arn
  }
}


# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "scep_lb_listener" {
  load_balancer_arn = aws_alb.lb.id
  port              = var.scep_app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.scep.arn
    type             = "forward"
  }
}

resource "aws_alb_listener" "nanomdm_lb_listener" {
  load_balancer_arn = aws_alb.lb.id
  port              = var.nanomdm_app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.nanomdm.arn
    type             = "forward"
  }
}
