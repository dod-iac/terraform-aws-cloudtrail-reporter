variable "tags" {
  type = object({
    Project     = string
    Environment = string
    Application = string
  })
  default = {
    Project     = "elmo"
    Environment = "dev"
    Application = "infra"
  }
}

variable "include_global_service_events" {
  type    = bool
  default = true
}
variable "kinesis_stream_arn" {
  type = string
}
variable "enable_bucket_force_destroy"{
  type = bool
  default = true
}



locals {
  project     = var.tags.Project
  environment = var.tags.Environment
  application = var.tags.Application
  name_prefix = format("%s-%s-%s-%s", random_string.prefix.id, local.project, local.application, local.environment)
}

resource "random_string" "prefix" {
  keepers = {
    project     = local.project
    environment = local.environment
    application = local.application
  }
  length  = 8
  special = false
  upper   = false

}
