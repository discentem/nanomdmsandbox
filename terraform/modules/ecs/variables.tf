# ECS Variables
variable "family" {
  type        = string
  description = "A unique name for your task definition."
  default     = ""
}

variable "memory" {
  type        = number
  description = "ECS Memory Requirements"
  default     = 4096
}

variable "cpu" {
  type        = number
  description = "ECS CPU Requirements"
  default     = 2048
}

variable "network_mode" {
  type        = string
  description = "Network mode for ECS Task Definition: [awsvpc,]. Defaults to awsvpc."
  default     = "awsvpc"
}

variable "requires_compatibilities" {
  type        = list
  description = "ECS Task Definition: : [FARGATE,]. Defaults to FARGATE."
  default     = ["FARGATE"]
}

# # ECS Variables
variable "ecs_service_name" {
  type        = string
  description = "ECS Service Name"
}

variable "desired_count" {
  type        = number
  description = "ECS desired count"
  default     = 2
}

variable "launch_type" {
  type        = string
  description = "ECS launch type"
  default = "FARGATE"
}
