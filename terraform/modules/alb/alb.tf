resource "aws_alb" "alb" {
  name               = "${var.prefix}-${var.name}-alb"
  internal           = var.internal_alb
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = [var.security_group_ids]
}

resource "aws_alb_target_group" "alb_target_group" {
  name         = "${var.prefix}-${var.name}-alb-target-group"
  protocol    = "HTTPS"
  port        = var.port
  target_type = "ip"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = var.port
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  depends_on = [aws_alb_target_group.alb_target_group]
}
resource "aws_alb_listener" "api_ssl_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_target_group.arn
  }

  depends_on = [
    aws_alb_target_group.alb_target_group
  ]
}

resource "aws_alb_listener" "http_to_https_redirect" {
  load_balancer_arn = aws_alb.alb_target_group.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  depends_on = [aws_alb_target_group.alb_target_group]
}