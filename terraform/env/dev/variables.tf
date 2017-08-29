# Dev environment Variables
# Davy Jones
# Cloudreach

variable "env" {
  description = "Enviroment Name of the VPC"
}

variable "aws_region" {
  description = "AWS Region to use"
}

variable "prefix" {
  description = "Naming prefix to apply to Name Tag"
}

variable "owner" {
  description = "Identifying name of person who owns resource. This will be used as Owner Tag"
}

variable "cidr_range" {
  description = "/16 CIDR Range to use"
}

variable "azs" {
  description = "string of availablility zones, seperated by comma"
}

variable "public_subnets" {
  description = "string of dev public subnet CIDRs, seperated by comma"
}

variable "private_subnets" {
  description = "string of dev private subnet CIDRs, seperated by comma"
}

variable "in_allowed_cidr_blocks" {
  description = "string of allowed ingress cidr_blocks to be used by Security group"
}

variable "domain_name" {
  description = "The name of the domain to use"
}

variable "ssh_key_pair_name" {
  description = "Name of the EC2 Key pair to use. THIS MUST BE CREATED BEFORE HAND!"
}

variable "ecs_ami" {
  description = "The AMI ID to use for the ECS Cluster. This should be an ECS optimized instance"
}

variable "ecs_instance_type" {
  description = "The size of EC2 instance to use for the ECS Cluster"
}

variable "ecs_max_size" {
  description = "The maximum size of the ECS Cluster"
}

variable "ecs_min_size" {
  description = "The minimum size of the ECS Cluster"
}

variable "ecs_desired_capacity" {
  description = "The desired size of the ECS Cluster"
}

variable "email" {
  description = "A users email address to use for subscribing to an SNS topic"
}
