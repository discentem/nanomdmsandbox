[
  {
    "name": "${prefix_app_name}-scep",
    "image": "${scep_container_image}",
    "portMappings": [
        {
          "containerPort": "${scep_app_port}",
          "hostPort": "${scep_app_port}",
          "protocol": "tcp"
        }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${awslogs_group}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "environment": "${environment}",
    "memory": "${scep_task_container_memory}",
    "cpu": "${scep_task_container_cpu}"
  },
  {
    "name": "${prefix_app_name}-nanomdm",
    "image": "${nanomdm_container_image}",
    "portMappings": [
        {
          "containerPort": "${nanomdm_app_port}",
          "hostPort": "${nanomdm_app_port}",
          "protocol": "tcp"
        }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${awslogs_group}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "environment": "${environment}",
    "memory": "${nanomdm_task_container_memory}",
    "cpu": "${nanomdm_task_container_cpu}"
  }
]