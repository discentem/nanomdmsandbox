resource "aws_alb" "lb" {
  name            = local.prefix_app_name
  subnets         = var.public_subnet_ids
  load_balancer_type = "application"
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

// Create target groups for each service //

// SCEP target group //
resource "aws_alb_target_group" "scep" {
  name_prefix = "sceptg"
  # name        = "${local.prefix_app_name}-scep-tg"
  port        = var.scep_app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

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
  lifecycle {
    create_before_destroy = true
  }
}

// NanoMDM target group //
resource "aws_alb_target_group" "nanomdm" {
  name_prefix = "nanotg"
  # name        = "${local.prefix_app_name}-nanomdm-tg"
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
  lifecycle {
    create_before_destroy = true
  }
}

// micro2nano target group //
resource "aws_alb_target_group" "micro2nano" {
  name_prefix = "m2ntg"
  # name        = "${local.prefix_app_name}-nanomdm-tg"
  port        = var.micro2nano_app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  dynamic "health_check" {
    for_each = [var.micro2nano_health_check]
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
  lifecycle {
    create_before_destroy = true
  }
}

// mdmdirector target group //
resource "aws_alb_target_group" "mdmdirector" {
  name_prefix = "mdirtg"
  port        = var.mdmdirector_app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  dynamic "health_check" {
    for_each = [var.mdmdirector_health_check]
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
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_alb_listener_rule" "nanomdm" {
  listener_arn = aws_alb_listener.https.arn
  # priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.nanomdm.arn
  }

  condition {
    path_pattern {
      values = ["/version", "/v1/pushcert", "/v1/push/*", "/v1/enqueue/*"]
    }
  }

  # condition {
  #   host_header {
  #     values = ["${var.lb_subdomain_name}.${var.domain_name}"]
  #   }
  # }
}

resource "aws_alb_listener_rule" "scep" {
  listener_arn = aws_alb_listener.https.arn
  # priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.scep.arn
  }

  condition {
    path_pattern {
      values = ["/scep", "/scep/*", "/scep*"]
    }
  }

  # condition {
  #   host_header {
  #     values = ["${var.lb_subdomain_name}.${var.domain_name}"]
  #   }
  # }
}

# resource "aws_alb_listener_rule" "micro2nano" {
#   listener_arn = aws_alb_listener.https.arn
#   # priority     = 100

#   action {
#     type             = "forward"
#     # target_group_arn = aws_lb_target_group.static.arn
#     target_group_arn = aws_alb_target_group.micro2nano.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/v1/commands", "/v1/commands/*"]
#     }
#   }

#   # condition {
#   #   host_header {
#   #     values = ["${var.lb_subdomain_name}.${var.domain_name}"]
#   #   }
#   # }
# }

resource "aws_alb_listener_rule" "mdmdirector" {
  listener_arn = aws_alb_listener.https.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.mdmdirector.arn
  }

  condition {
    path_pattern {
      values = ["/v1/commands", "/v1/commands/*"]
    }
  }
}

// Attach all application target groups to the listeners //
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

resource "aws_alb_listener" "micro2nano_lb_listener" {
  load_balancer_arn = aws_alb.lb.id
  port              = var.micro2nano_app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.micro2nano.arn
    type             = "forward"
  }
}
