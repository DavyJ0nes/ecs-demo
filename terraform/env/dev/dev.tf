# Creates an ECS Cluster behind ALB
# Development Stack
# Davy Jones 2017
# Cloudreach

terraform {
  backend "s3" {
    bucket = "cr-davy-agileops-training"
    key    = "terraform/ecs_cluster-dev"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

#---------- SET UP VPC ----------#

module "vpc" {
  source          = "../../modules/vpc"
  env             = "${var.env}"
  prefix          = "${var.prefix}"
  owner           = "${var.owner}"
  vpc_cidr        = "${var.cidr_range}"
  azs             = "${var.azs}"
  public_subnets  = "${var.public_subnets}"
  private_subnets = "${var.private_subnets}"
}

#---------- SET UP ECR REPO ----------#

module "ecr" {
  source = "../../modules/ecr"
  env    = "${var.env}"
  prefix = "${var.prefix}"
}

#---------- SET UP ECS CLUSTER ----------#

module "ecs" {
  source           = "../../modules/ecs"
  env              = "${var.env}"
  prefix           = "${var.prefix}"
  owner            = "${var.owner}"
  vpc_id           = "${module.vpc.vpc_id}"
  ami              = "${var.ecs_ami}"
  instance_type    = "${var.ecs_instance_type}"
  domain           = "${var.domain_name}"
  key_name         = "${var.ssh_key_pair_name}"
  max_size         = "${var.ecs_max_size}"
  min_size         = "${var.ecs_min_size}"
  desired_capacity = "${var.ecs_desired_capacity}"
  subnets          = "${module.vpc.private_subnet_ids}"
}

#---------- DEPLOY CONTAINERS ---------#


#---------- SET UP TESTING LAMBDA --------#


#---------- SET UP CLOUDWATCH MONITORING ---------#

