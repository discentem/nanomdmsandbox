output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the ECS cluster."
  value       = aws_ecs_cluster.cluster.arn
}

output "cluster_id" {
  description = "The ID that identifies the ECS cluster."
  value       = aws_ecs_cluster.cluster.id
}