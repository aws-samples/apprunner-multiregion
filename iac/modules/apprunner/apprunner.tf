variable "image" {
  description = "the container image to use"
  type        = string
}

variable "health_check" {
  description = "healthcheck path"
  type        = string
  default     = "/health"
}

variable "port" {
  type        = string
  default     = "8080"
  description = "port"
}

variable "cpu" {
  type        = number
  default     = 1024
  description = "cpu"
}

variable "memory" {
  type        = number
  default     = 2048
  description = "memory"
}

variable "health_check_protocol" {
  description = "The IP protocol that App Runner uses to perform health checks for your service."
  type        = string
  default     = "HTTP"
}

variable "health_check_healthy_threshold" {
  description = "The number of consecutive checks that must succeed before App Runner decides that the service is healthy."
  type        = number
  default     = 1
}

variable "health_check_interval" {
  description = "The time interval, in seconds, between health checks."
  type        = number
  default     = 5
}

variable "health_check_unhealthy_threshold" {
  description = "The number of consecutive checks that must fail before App Runner decides that the service is unhealthy. "
  type        = number
  default     = 5
}

variable "health_check_timeout" {
  description = "The time, in seconds, to wait for a health check response before deciding it failed."
  type        = number
  default     = 2
}

resource "aws_apprunner_service" "main" {
  service_name = var.app
  tags         = var.tags

  source_configuration {
    auto_deployments_enabled = false

    authentication_configuration {
      access_role_arn = aws_iam_role.access.arn
    }

    image_repository {
      image_repository_type = "ECR"
      image_identifier      = var.image
      image_configuration {
        port = var.port
        runtime_environment_variables = {
          DYNAMO_TABLE = var.app
        }
      }
    }
  }

  instance_configuration {
    instance_role_arn = aws_iam_role.instance.arn
    cpu               = var.cpu
    memory            = var.memory
  }

  health_check_configuration {
    protocol            = var.health_check_protocol
    path                = var.health_check
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }
}

output "service_arn" {
  value = aws_apprunner_service.main.arn
}

output "service_id" {
  value = aws_apprunner_service.main.service_id
}

output "service_url" {
  value = "https://${aws_apprunner_service.main.service_url}"
}

