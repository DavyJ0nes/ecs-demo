# ECS Service Module
# DavyJ0nes 2017

variable "env" {
  description = "The Environment name of the Cluster"
}

variable "prefix" {
  description = "Naming prefix to use"
}

variable "owner" {
  description = "The tag value to use for the owner tag"
}

variable "name" {
  description = "The name of the task i.e. api, frontend etc"
}

variable "definition" {
  description = "The container definition file: https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html"
}

variable "cluster_name" {
  description = "The name of the ecs cluster to run the service within"
}

variable "desired_count" {
  description = "The desired numer of containers(tasks) to run"
}

variable "target_group" {
  description = "The ALB target group to associate the service with"
}

variable "container_name" {
  description = "The name of the container to use"
}

variable "container_port" {
  description = "the container port to communicate over"
}
