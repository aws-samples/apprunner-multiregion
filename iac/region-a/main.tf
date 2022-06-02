provider "aws" {
  region = var.region
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "The AWS region to use"
}

variable "app" {
  type        = string
  description = "Name of the application"
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to apply to various resources"
  default     = {}
}

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

variable "route53_zone" {
  description = "The custom domain endpoint to associate"
  type        = string
}

variable "app_sub_domain" {
  description = "The app sub domain"
  type        = string
}

module "apprunner" {
  source = "../modules/apprunner"

  region                           = var.region
  app                              = var.app
  tags                             = var.tags
  image                            = var.image
  health_check                     = var.health_check
  port                             = var.port
  route53_zone                     = var.route53_zone
  app_sub_domain                   = var.app_sub_domain
  cpu                              = var.cpu
  memory                           = var.memory
  health_check_protocol            = var.health_check_protocol
  health_check_timeout             = var.health_check_timeout
  health_check_interval            = var.health_check_interval
  health_check_unhealthy_threshold = var.health_check_unhealthy_threshold
}

output "region" {
  value = var.region
}

output "service_arn" {
  value = module.apprunner.service_arn
}

output "service_id" {
  value = module.apprunner.service_id
}

output "service_url" {
  value = module.apprunner.service_url
}

output "custom_service_url" {
  value = module.apprunner.custom_service_url
}

output "image" {
  value = var.image
}
