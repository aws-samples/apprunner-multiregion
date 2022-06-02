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

variable "region_alternate" {
  description = "the destination region for ecr cross region replication as well as dynamo replication"
  type        = string
}

