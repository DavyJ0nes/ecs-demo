# Development Stack
# Davy Jones 2017

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

#---------- SET UP API ECR REPO ----------#

module "api_ecr" {
  source = "../../modules/ecr"
  prefix = "${var.prefix}"
  app    = "api"
}

#---------- SET UP FRONT END ECR REPO ----------#

module "frontend_ecr" {
  source = "../../modules/ecr"
  prefix = "${var.prefix}"
  app    = "frontend"
}

#---------- SET UP ECS CLUSTER ----------#

module "ecs_cluster" {
  source           = "../../modules/ecs/cluster"
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
  subnets          = "${module.vpc.public_subnet_ids}"
}

#---------- CREATE ECS SERVICE ---------#


# module "ecs_service" {
#   source  = "../../modules/ecs/service"
#   env     = "${var.env}"
#   prefix  = "${var.prefix}"
#   owner   = "${var.owner}"
#   cluster = "${module.ecs_cluster.name}"
# }


#---------- SET UP TESTING LAMBDA --------#


# module "lambda" {}


#---------- SET UP CLOUDWATCH MONITORING ---------#


# module "cloudwatch" {}


#---------- SET UP ROUTE 53 ENDPOINT ---------#


# module "route53" {}

