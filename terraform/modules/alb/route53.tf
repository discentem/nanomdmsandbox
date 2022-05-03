resource "aws_route53_record" "alb_record" {
  count   = var.internal_alb ? 0 : 1
  zone_id = var.zone_id
  name    = var.alb_domain_name
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.alb.dns_name]
}