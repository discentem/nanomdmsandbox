output "arn" {
  value = aws_ecr_repository.ecr_repository.arn
}

output "registry_id" {
  value = aws_ecr_repository.ecr_repository.registry_id
}

output "repository_url" {
  value = aws_ecr_repository.ecr_repository.repository_url
}
