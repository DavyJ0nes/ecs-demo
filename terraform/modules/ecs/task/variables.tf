# ECS Task Module Variables
# DavyJ0nes 2017

variable "env" {
  description = "The Environment name of the Cluster"
}

variable "prefix" {
  description = "Naming prefix to use"
}

variable "service" {
  description = "The name of the service i.e. api, frontend etc"
}

variable "task_name" {
  description = "The name of the task to use within the definition file"
}

variable "task_image_url" {
  description = "The url of the task(container image) to user within the task definition file"
}

variable "task_container_port" {
  description = "The port number to use within the task definition file"
}
