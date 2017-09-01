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

variable "cluster_name" {
  description = "The name of the ecs cluster to run the service within"
}

variable "iam_role" {
  description = "The ECS IAM role to assume"
}

variable "desired_count" {
  description = "The desired numer of containers(tasks) to run"
}

variable "definition_arn" {
  description = "The ARN of the task definition"
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
