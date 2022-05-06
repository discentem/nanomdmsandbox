output "id" {
  value = aws_secretsmanager_secret.secret.id
}

output "arn" {
  value       = aws_secretsmanager_secret.secret.arn
}