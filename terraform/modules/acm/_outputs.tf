output "acm_certificate_id" {
  value = aws_acm_certificate.this.id
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.this.arn
}

output "acm_certificate_domain_name" {
  value = aws_acm_certificate.this.domain_name
}

output "acm_certificate_domain_validation_options" {
  value = aws_acm_certificate.this.domain_validation_options
}

output "acm_certificate_status" {
  value = aws_acm_certificate.this.status
}
