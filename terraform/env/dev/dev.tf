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

#---------- CREATE ECS FRONTEND TASK ---------#

module "ecs_frontend_task" {
  source              = "../../modules/ecs/task"
  env                 = "${var.env}"
  prefix              = "${var.prefix}"
  service             = "frontend"
  task_name           = "${var.prefix}-ecs-frontend"
  task_image_url      = "${var.ecr_main_url}/${var.prefix}-frontend:latest"
  task_container_port = 8080
}

#---------- CREATE ECS FRONTEND SERVICE ---------#

module "ecs_frontend_service" {
  source         = "../../modules/ecs/service"
  env            = "${var.env}"
  prefix         = "${var.prefix}"
  owner          = "${var.owner}"
  name           = "frontend"
  cluster_name   = "${module.ecs_cluster.cluster_name}"
  desired_count  = 3
  iam_role       = "${module.ecs_cluster.ecs_iam_role_name}"
  definition_arn = "${module.ecs_frontend_task.task_definition_arn}"
  target_group   = "${module.ecs_cluster.frontend_tg_arn}"
  container_name = "${var.prefix}-ecs-frontend"
  container_port = 8080
}

#---------- CREATE ECS API TASK ---------#

module "ecs_api_task" {
  source              = "../../modules/ecs/task"
  env                 = "${var.env}"
  prefix              = "${var.prefix}"
  service             = "api"
  task_name           = "${var.prefix}-ecs-api"
  task_image_url      = "${var.ecr_main_url}/${var.prefix}-api:latest"
  task_container_port = 3000
}

#---------- CREATE ECS API SERVICE ---------#

module "ecs_api_service" {
  source         = "../../modules/ecs/service"
  env            = "${var.env}"
  prefix         = "${var.prefix}"
  owner          = "${var.owner}"
  name           = "api"
  cluster_name   = "${module.ecs_cluster.cluster_name}"
  desired_count  = 3
  iam_role       = "${module.ecs_cluster.ecs_iam_role_name}"
  definition_arn = "${module.ecs_api_task.task_definition_arn}"
  target_group   = "${module.ecs_cluster.api_tg_arn}"
  container_name = "${var.prefix}-ecs-api"
  container_port = 3000
}

#---------- SET UP TESTING LAMBDA --------#


# module "lambda" {}


#---------- SET UP CLOUDWATCH MONITORING ---------#


# module "cloudwatch" {}


#---------- SET UP ROUTE 53 ENDPOINT ---------#


# module "route53" {}

