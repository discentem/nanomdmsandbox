variable "prefix" {
  description = "A prefix used for naming resources."
  type        = string
}

variable "app_name" {
  description = "The application/service name used with the prefix for naming resources."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID."
  type        = string
}

variable "cluster_id" {
  description = "Cluster ID to use for the ECS Service"
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
}

variable "platform_version" {
  description = "The platform version on which to run your service. Only applicable for launch_type set to FARGATE."
  default     = "LATEST"
}

variable "container_definition_cpu" {
  description = "Amount of CPU to reserve for the task."
  default     = null
  type        = number
}

variable "container_definition_memory" {
  description = "The soft limit (in MiB) of memory to reserve for the task."
  default     = null
  type        = number
}
variable "scep_container_image" {
  description = "The SCEP image used to start a container."
  type        = string
}

variable "scep_app_port" {
  description = "The SCEP app port used for the container."
  type        = number
  default     = 8080
}

variable "scep_task_definition_cpu" {
  description = "Amount of CPU to reserve for the task."
  default     = 512
  type        = number
}

variable "scep_task_definition_memory" {
  description = "The soft limit (in MiB) of memory to reserve for the task."
  default     = 512
  type        = number
}

variable "nanomdm_container_image" {
  description = "The nanomdm image used to start a container."
  type        = string
}

variable "nanomdm_app_port" {
  description = "The nanomdm app port used for the container."
  type        = number
  default     = 9000
}

variable "nanomdm_task_definition_cpu" {
  description = "Amount of CPU to reserve for the task."
  default     = 256
  type        = number
}

variable "nanomdm_task_definition_memory" {
  description = "The soft limit (in MiB) of memory to reserve for the task."
  default     = 512
  type        = number
}

variable "nanomdm_task_container_environment" {
  description = "The environment variables to pass to a container."
  default     = {}
  type        = map(string)
}

variable "micro2nano_container_image" {
  description = "The micro2nano image used to start a container."
  type        = string
}

variable "micro2nano_app_port" {
  description = "The micro2nano app port used for the container."
  type        = number
  default     = 9001
}

variable "micro2nano_task_definition_cpu" {
  description = "Amount of CPU to reserve for the task."
  default     = 256
  type        = number
}

variable "micro2nano_task_definition_memory" {
  description = "The soft limit (in MiB) of memory to reserve for the task."
  default     = 512
  type        = number
}

variable "micro2nano_task_container_environment" {
  description = "The environment variables to pass to a container."
  default     = {}
  type        = map(string)
}

variable "default_task_definition_cpu" {
  description = "Amount of CPU to reserve for the task."
  default     = 256
  type        = number
}

variable "default_task_definition_memory" {
  description = "The soft limit (in MiB) of memory to reserve for the task."
  default     = 512
  type        = number
}

variable "desired_count" {
  description = "The number of instances of the task definitions to place and keep running."
  default     = 1
  type        = number
}

variable "task_container_assign_public_ip" {
  description = "Assigned public IP to the container."
  default     = false
  type        = bool
}


variable "task_container_protocol" {
  description = "Protocol that the container exposes."
  default     = "HTTP"
  type        = string
}

variable "default_task_definition_ephemeral_storage" {
  description = "The total amount, in GiB, of ephemeral storage to set for the task."
  default     = 0
  type        = number
}

variable "task_container_command" {
  description = "The command that is passed to the container."
  default     = []
  type        = list(string)
}

variable "task_container_environment" {
  description = "The environment variables to pass to a container."
  default     = {}
  type        = map(string)
}

variable "task_container_secrets" {
  description = "The secrets variables to pass to a container."
  default     = null
  type        = list(map(string))
}

variable "log_retention_in_days" {
  description = "Number of days the logs will be retained in CloudWatch."
  default     = 30
  type        = number
}

variable "scep_health_check" {
  description = "A health block containing health check settings for the target group. Overrides the defaults."
  type        = map(string)
}

variable "nanomdm_health_check" {
  description = "A health block containing health check settings for the target group. Overrides the defaults."
  type        = map(string)
}

variable "health_check_grace_period_seconds" {
  default     = 300
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 7200. Only valid for services configured to use load balancers."
  type        = number
}

variable "tags" {
  description = "A map of tags (key-value pairs) passed to resources."
  type        = map(string)
  default     = {}
}

variable "deployment_minimum_healthy_percent" {
  default     = 50
  description = "The lower limit of the number of running tasks that must remain running and healthy in a service during a deployment"
  type        = number
}

variable "deployment_maximum_percent" {
  default     = 200
  description = "The upper limit of the number of running tasks that can be running in a service during a deployment"
  type        = number
}

variable "deployment_controller_type" {
  default     = "ECS"
  type        = string
  description = "Type of deployment controller. Valid values: CODE_DEPLOY, ECS, EXTERNAL. Default: ECS."
}

variable "repository_credentials" {
  default     = ""
  description = "name or ARN of a secrets manager secret (arn:aws:secretsmanager:region:aws_account_id:secret:secret_name)"
  type        = string
}

variable "repository_credentials_kms_key" {
  default     = "alias/aws/secretsmanager"
  description = "key id, key ARN, alias name or alias ARN of the key that encrypted the repository credentials"
  type        = string
}

variable "create_repository_credentials_iam_policy" {
  default     = false
  description = "Set to true if you are specifying `repository_credentials` variable, it will attach IAM policy with necessary permissions to task role."
}

variable "service_registry_arn" {
  default     = ""
  description = "ARN of aws_service_discovery_service resource"
  type        = string
}

variable "propogate_tags" {
  type        = string
  description = "Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are SERVICE and TASK_DEFINITION."
  default     = "TASK_DEFINITION"
}

variable "target_groups" {
  type        = any
  default     = []
  description = "The name of the target groups to associate with ecs service"
}

variable "is_load_balanced" {
  type        = bool
  default     = true
  description = "Whether the task should be loadbalanced."
}

variable "logs_kms_key" {
  type        = string
  description = "The KMS key ARN to use to encrypt container logs."
  default     = ""
}

variable "capacity_provider_strategy" {
  type        = list(any)
  description = "(Optional) The capacity_provider_strategy configuration block. This is a list of maps, where each map should contain \"capacity_provider \", \"weight\" and \"base\""
  default     = []
}

variable "placement_constraints" {
  type        = list(any)
  description = "(Optional) A set of placement constraints rules that are taken into consideration during task placement. Maximum number of placement_constraints is 10. This is a list of maps, where each map should contain \"type\" and \"expression\""
  default     = []
}

variable "proxy_configuration" {
  type        = list(any)
  description = "(Optional) The proxy configuration details for the App Mesh proxy. This is a list of maps, where each map should contain \"container_name\", \"properties\" and \"type\""
  default     = []
}

variable "volume" {
  description = "(Optional) A set of volume blocks that containers in your task may use. This is a list of maps, where each map should contain \"name\", \"host_path\", \"docker_volume_configuration\" and \"efs_volume_configuration\". Full set of options can be found at https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html"
  default     = []
}

variable "task_health_command" {
  type        = list(string)
  description = "A string array representing the command that the container runs to determine if it is healthy."
  default     = null
}

variable "task_health_check" {
  type        = map(number)
  description = "An optional healthcheck definition for the task"
  default     = null
}

variable "task_container_memory_reservation" {
  description = "The soft limit (in MiB) of memory to reserve for the container."
  default     = null
  type        = number
}

variable "task_container_working_directory" {
  description = "The working directory to run commands inside the container."
  default     = ""
  type        = string
}

variable "task_start_timeout" {
  type        = number
  description = "Time duration (in seconds) to wait before giving up on resolving dependencies for a container. If this parameter is not specified, the default value of 3 minutes is used (fargate)."
  default     = null
}

variable "task_stop_timeout" {
  type        = number
  description = "Time duration (in seconds) to wait before the container is forcefully killed if it doesn't exit normally on its own. The max stop timeout value is 120 seconds and if the parameter is not specified, the default value of 30 seconds is used."
  default     = null
}

variable "task_mount_points" {
  description = "The mount points for data volumes in your container. Each object inside the list requires \"sourceVolume\", \"containerPath\" and \"readOnly\". For more information see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html "
  type        = list(object({ sourceVolume = string, containerPath = string, readOnly = bool }))
  default     = null
}

variable "task_pseudo_terminal" {
  type        = bool
  description = "Allocate TTY in the container"
  default     = null
}

variable "force_new_deployment" {
  type        = bool
  description = "Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination (e.g. myimage:latest), roll Fargate tasks onto a newer platform version."
  default     = false
}

variable "wait_for_steady_state" {
  type        = bool
  description = "If true, Terraform will wait for the service to reach a steady state (like aws ecs wait services-stable) before continuing."
  default     = false
}

variable "enable_execute_command" {
  type        = bool
  description = "Specifies whether to enable Amazon ECS Exec for the tasks within the service."
  default     = true
}


variable "zone_id" {
  type        = string
  description = ""
  default     = null
}

variable "domain_name" {
  type        = string
  description = ""
  default     = null
}

variable "lb_subdomain_name" {
  type        = string
  description = ""
  default     = "nanomdm-infra"
}

variable "certificate_arn" {
  type        = string
  description = ""
}

variable "mysql_secrets_manager_arn" {
  type        = string
  description = ""
}

variable "public_inbound_cidr_blocks_ipv4" {
  type = list(string)
  description = "list of allowed CIDRs to reach public resources"
}

variable "public_inbound_cidr_blocks_ipv6" {
  type = list(string)
  description = "list of allowed CIDRs to reach public resources"
}
