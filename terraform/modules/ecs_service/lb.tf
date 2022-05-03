resource "aws_alb" "lb" {
  name            = local.prefix_app_name
  subnets         = var.public_subnet_ids
  security_groups = [aws_security_group.lb.id]
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
