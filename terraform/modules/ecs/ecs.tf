resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = var.family
  container_definitions    = "{INSERT_HERE}"
  requires_compatibilities = var.requires_compatibilities
  memory                   = var.memory
  cpu                      = var.cpu
  network_mode             = var.network_mode
  execution_role_arn       = aws_iam_role.iam_ecs_role.arn
  task_role_arn            = aws_iam_role.iam_ecs_role.arn
}

# ECS Service
resource "aws_ecs_service" "ecs_service" {
  name                               = var.ecs_service_name
  cluster                            = var.ecs_cluster
  desired_count                      = var.desired_count
  task_definition                    = aws_ecs_task_definition.ecs_task_definition.id
  # TODO: Update these to vars
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"

  # TODO: ALB is Needed
  load_balancer {
    target_group_arn = aws_alb_target_group.ecs_alb_target_group.arn
    container_name   = "{INSERT_HERE}"
    container_port   = 25565
  }
  
  # TODO: ALB is Needed
  network_configuration {
    subnets          = []
    security_groups  = [aws_security_group.ecs_alb.id]
    assign_public_ip = var.internal_alb ? false : true
  }
}
