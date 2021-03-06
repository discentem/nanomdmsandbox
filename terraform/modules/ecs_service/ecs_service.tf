locals {
  task_environment = [
    for k, v in var.task_container_environment : {
      name  = k
      value = v
    }
  ]
  nanomdm_task_environment = [
    for k, v in var.nanomdm_task_container_environment : {
      name  = k
      value = v
    }
  ]
  micro2nano_task_environment = [
    for k, v in var.micro2nano_task_container_environment : {
      name  = k
      value = v
    }
  ]
  enroll_endpoint_task_environment = [
    for k, v in var.enroll_endpoint_task_container_environment : {
      name  = k
      value = v
    }
  ]
}

// NanoMDM Task Definition //
module "nanomdm" {
  source = "../../modules/ecs_task_definition"

  name =  "${var.app_name}-nanomdm"

  image     = "${var.nanomdm_container_image}"
  essential = true

  portMappings = [
    {
      containerPort =  var.nanomdm_app_port
      hostPort = var.nanomdm_app_port
      protocol = "tcp"
    },
  ]

  logConfiguration = {
    logDriver = "awslogs"
    options = {
      awslogs-group = "${aws_cloudwatch_log_group.main.name}"
      awslogs-region ="${data.aws_region.current.name}"
      awslogs-stream-prefix = "ecs"
    }
  }

  secrets = [
    {
      "name": "MYSQL_PASSWORD",
      "valueFrom": "${var.mysql_secrets_manager_arn}:MYSQL_PASSWORD::"
    },
    {
      "name": "MYSQL_USERNAME",
      "valueFrom": "${var.mysql_secrets_manager_arn}:MYSQL_USERNAME::"
    },
    {
      "name": "MYSQL_HOSTNAME",
      "valueFrom": "${var.mysql_secrets_manager_arn}:MYSQL_HOSTNAME::"
    },
    {
      "name": "MYSQL_DSN",
      "valueFrom": "${var.mysql_secrets_manager_arn}:MYSQL_DSN::"
    },
    {
      "name": "API_KEY",
      "valueFrom": "${var.nanomdm_secrets_manager_arn}:API_KEY::"
    }
  ]

  environment = local.nanomdm_task_environment

  memory = var.nanomdm_task_definition_memory
  cpu    = var.nanomdm_task_definition_cpu

  register_task_definition = false
}

// SCEP Task Definition //
module "scep" {
 source = "../../modules/ecs_task_definition"

  name =  "${var.app_name}-scep"

  image     = "${var.scep_container_image}"
  essential = true

  portMappings = [
    {
      containerPort =  var.scep_app_port
      hostPort = var.scep_app_port
      protocol = "tcp"
    },
  ]

  logConfiguration = {
    logDriver = "awslogs"
    options = {
      awslogs-group = "${aws_cloudwatch_log_group.main.name}"
      awslogs-region ="${data.aws_region.current.name}"
      awslogs-stream-prefix = "ecs"
    }
  }

  secrets = [
    {
      "name": "CHALLENGE",
      "valueFrom": "${var.scep_secrets_manager_arn}:SCEP_CHALLENGE::"
    }
  ]

  environment = local.task_environment

  memory = var.scep_task_definition_memory
  cpu    = var.scep_task_definition_cpu

  register_task_definition = false
}

// micro2nano Task Definition //
module "micro2nano" {
  source = "../../modules/ecs_task_definition"

  name =  "${var.app_name}-micro2nano"

  image     = "${var.micro2nano_container_image}"
  essential = true

  portMappings = [
    {
      containerPort =  var.micro2nano_app_port
      hostPort = var.micro2nano_app_port
      protocol = "tcp"
    },
  ]

  logConfiguration = {
    logDriver = "awslogs"
    options = {
      awslogs-group = "${aws_cloudwatch_log_group.main.name}"
      awslogs-region ="${data.aws_region.current.name}"
      awslogs-stream-prefix = "ecs"
    }
  }

  secrets = [
    {
      "name": "NANO_API_KEY",
      "valueFrom": "${var.nanomdm_secrets_manager_arn}:API_KEY::"
    },
    {
      "name": "MICROMDM_API_KEY",
      "valueFrom": "${var.micro2nano_secrets_manager_arn}:MICROMDM_API_KEY::"
    }
  ]

  environment = local.micro2nano_task_environment

  memory = var.micro2nano_task_definition_memory
  cpu    = var.micro2nano_task_definition_cpu

  register_task_definition = false
}

// MDMDirector Task Definition //
module "mdmdirector" {
  source = "../../modules/ecs_task_definition"

  name =  "${var.app_name}-mdmdirector"

  image     = "${var.mdmdirector_container_image}"
  essential = true

  portMappings = [
    {
      containerPort =  var.mdmdirector_app_port
      hostPort = var.mdmdirector_app_port
      protocol = "tcp"
    },
  ]

  logConfiguration = {
    logDriver = "awslogs"
    options = {
      awslogs-group = "${aws_cloudwatch_log_group.main.name}"
      awslogs-region ="${data.aws_region.current.name}"
      awslogs-stream-prefix = "ecs"
    }
  }

  secrets = [
    {
      "name": "DB_PASSWORD",
      "valueFrom": "${var.psql_secrets_manager_arn}:PSQL_PASSWORD::"
    },
    {
      "name": "DB_USERNAME",
      "valueFrom": "${var.psql_secrets_manager_arn}:PSQL_USERNAME::"
    },
    {
      "name": "DB_HOSTNAME",
      "valueFrom": "${var.psql_secrets_manager_arn}:PSQL_HOSTNAME::"
    },
    {
      "name": "MICROMDM_API_KEY",
      "valueFrom": "${var.micro2nano_secrets_manager_arn}:MICROMDM_API_KEY::"
    },
    {
      "name": "MDMDIRECTOR_API_KEY",
      "valueFrom": "${var.mdmdirector_secrets_manager_arn}:MDMDIRECTOR_API_KEY::"
    }
  ]

  environment = local.task_environment

  memory = var.mdmdirector_task_definition_memory
  cpu    = var.mdmdirector_task_definition_cpu

  register_task_definition = false
}

// Redis Task Definition //
module "redis" {
  source = "../../modules/ecs_task_definition"

  name =  "${var.app_name}-redis"

  image     = "redis"
  essential = true

  portMappings = [
    {
      containerPort =  6379
      hostPort = 6379
      protocol = "tcp"
    },
  ]

  logConfiguration = {
    logDriver = "awslogs"
    options = {
      awslogs-group = "${aws_cloudwatch_log_group.main.name}"
      awslogs-region ="${data.aws_region.current.name}"
      awslogs-stream-prefix = "ecs"
    }
  }

  environment = local.task_environment

  memory = var.default_task_definition_memory
  cpu    = var.default_task_definition_cpu

  register_task_definition = false
}

// Enroll Endpoint Task Definition //
module "enroll_endpoint" {
  source = "../../modules/ecs_task_definition"

  name =  "${var.app_name}-enroll-endpoint"

  image     = "${var.enroll_endpoint_container_image}"
  essential = false

  portMappings = [
    {
      containerPort =  var.enroll_endpoint_app_port
      hostPort = var.enroll_endpoint_app_port
      protocol = "tcp"
    },
  ]

  logConfiguration = {
    logDriver = "awslogs"
    options = {
      awslogs-group = "${aws_cloudwatch_log_group.main.name}"
      awslogs-region ="${data.aws_region.current.name}"
      awslogs-stream-prefix = "ecs"
    }
  }

  secrets = [
    {
      "name": "SCEP_CHALLENGE",
      "valueFrom": "${var.scep_secrets_manager_arn}:SCEP_CHALLENGE::"
    }
  ]

  environment = local.enroll_endpoint_task_environment

  memory = var.enroll_endpoint_task_definition_memory
  cpu    = var.enroll_endpoint_task_definition_cpu

  register_task_definition = false
}


// Combine all task definitions //
module "merged" {
 source = "../../modules/ecs_task_definition//modules/merge"

 container_definitions = [
   "${module.nanomdm.container_definitions}",
   "${module.scep.container_definitions}",
   "${module.micro2nano.container_definitions}",
   "${module.mdmdirector.container_definitions}",
   "${module.redis.container_definitions}",
   "${module.enroll_endpoint.container_definitions}",
 ]
}

// Build the unified task definitions //
resource "aws_ecs_task_definition" "task" {
  family                   = local.prefix_app_name
  execution_role_arn       = aws_iam_role.execution.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_definition_cpu
  memory                   = var.container_definition_memory
  task_role_arn            = aws_iam_role.task.arn
  container_definitions    = "${module.merged.container_definitions}"

  dynamic "ephemeral_storage" {
    for_each = var.default_task_definition_ephemeral_storage == 0 ? [] : [var.default_task_definition_ephemeral_storage]
    content {
      size_in_gib = var.default_task_definition_ephemeral_storage
    }
  }

  dynamic "placement_constraints" {
    for_each = var.placement_constraints
    content {
      expression = lookup(placement_constraints.value, "expression", null)
      type       = placement_constraints.value.type
    }
  }

  dynamic "proxy_configuration" {
    for_each = var.proxy_configuration
    content {
      container_name = proxy_configuration.value.container_name
      properties     = lookup(proxy_configuration.value, "properties", null)
      type           = lookup(proxy_configuration.value, "type", null)
    }
  }

  dynamic "volume" {
    for_each = var.volume
    content {
      name      = volume.value.name
      host_path = lookup(volume.value, "host_path", null)

      dynamic "docker_volume_configuration" {
        for_each = lookup(volume.value, "docker_volume_configuration", [])
        content {
          scope         = lookup(docker_volume_configuration.value, "scope", null)
          autoprovision = lookup(docker_volume_configuration.value, "autoprovision", null)
          driver        = lookup(docker_volume_configuration.value, "driver", null)
          driver_opts   = lookup(docker_volume_configuration.value, "driver_opts", null)
          labels        = lookup(docker_volume_configuration.value, "labels", null)
        }
      }

      dynamic "efs_volume_configuration" {
        for_each = lookup(volume.value, "efs_volume_configuration", [])
        content {
          file_system_id          = lookup(efs_volume_configuration.value, "file_system_id", null)
          root_directory          = lookup(efs_volume_configuration.value, "root_directory", null)
          transit_encryption      = lookup(efs_volume_configuration.value, "transit_encryption", null)
          transit_encryption_port = lookup(efs_volume_configuration.value, "transit_encryption_port", null)

          dynamic "authorization_config" {
            for_each = length(lookup(efs_volume_configuration.value, "authorization_config", {})) == 0 ? [] : [lookup(efs_volume_configuration.value, "authorization_config", {})]
            content {
              access_point_id = lookup(authorization_config.value, "access_point_id", null)
              iam             = lookup(authorization_config.value, "iam", null)
            }
          }
        }
      }
    }
  }

  tags = merge(
    var.tags,
  )
}

resource "aws_ecs_service" "service" {
  name = var.app_name

  cluster         = var.cluster_id
  task_definition = "${aws_ecs_task_definition.task.family}:${max(aws_ecs_task_definition.task.revision, data.aws_ecs_task_definition.task.revision)}"

  desired_count  = var.desired_count
  propagate_tags = var.propogate_tags

  platform_version = var.platform_version
  launch_type      = length(var.capacity_provider_strategy) == 0 ? "FARGATE" : null

  force_new_deployment   = var.force_new_deployment
  wait_for_steady_state  = var.wait_for_steady_state
  enable_execute_command = var.enable_execute_command

  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  health_check_grace_period_seconds  = var.is_load_balanced ? var.health_check_grace_period_seconds : null

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = var.task_container_assign_public_ip
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
      base              = lookup(capacity_provider_strategy.value, "base", null)
    }
  }

  // Load Balancers for all services //

  load_balancer {
    target_group_arn = aws_alb_target_group.nanomdm.arn
    container_name   = "${var.app_name}-nanomdm"
    container_port   = var.nanomdm_app_port
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.scep.arn
    container_name   = "${var.app_name}-scep"
    container_port   = var.scep_app_port
  }

  # load_balancer {
  #   target_group_arn = aws_alb_target_group.micro2nano.arn
  #   container_name   = "${var.app_name}-micro2nano"
  #   container_port   = var.micro2nano_app_port
  # }

  load_balancer {
    target_group_arn = aws_alb_target_group.mdmdirector.arn
    container_name   = "${var.app_name}-mdmdirector"
    container_port   = var.mdmdirector_app_port
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.enroll_endpoint.arn
    container_name   = "${var.app_name}-enroll-endpoint"
    container_port   = var.enroll_endpoint_app_port
  }

  deployment_controller {
    type = var.deployment_controller_type
  }

  dynamic "service_registries" {
    for_each = var.service_registry_arn == "" ? [] : [1]
    content {
      registry_arn   = var.service_registry_arn
      container_name = var.container_name != "" ? var.container_name : var.prefix
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${local.prefix_app_name}-service"
    },
  )
}