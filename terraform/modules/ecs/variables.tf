# ECS Module Variables
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

variable "vpc_id" {
  description = "The ID of the VPC to attach to ECS SG"
}

variable "ami" {
  description = "The AMI ID to use for the ECS instances"
}

variable "instance_type" {
  description = "The instance type to use for the ECS instances"
}

variable "domain" {
  description = "The Domain Name that is linked to the ACM TLS Certificate. This is used with the ALB"
}

variable "key_name" {
  description = "The SSH public key name to use to access the ECS Instances"
}

variable "max_size" {
  description = "The maximum number of instances to be allowed within the ECS Cluster ASG"
}

variable "min_size" {
  description = "The minimum number of instances to be allowed within the ECS Cluster ASG"
}

variable "desired_capacity" {
  default     = 3
  description = "The optimum number of instances to have within the ECS Cluster ASG"
}

variable "subnets" {
  description = "A string comma seperated list of subnets to attach to the ECS Cluster ASG"
}
