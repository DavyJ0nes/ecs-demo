# ECS Module

## Description
Terraform module that creates an ECS cluster and maanges the ECS Services and Tasks. It is broken up into three modules:

- Cluster. Creates an Autoscaling group, Application load balancer and target groups for the services as well as the ECS cluster itself.
- Tasks. Creates task definitions for the services.
- Service. Creates the ECS services.

## Usage
```
## cluster
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

## task
module "ecs_frontend_task" {
  source              = "../../modules/ecs/task"
  env                 = "${var.env}"
  prefix              = "${var.prefix}"
  service             = "frontend"
  task_name           = "${var.prefix}-ecs-frontend"
  task_image_url      = "${var.ecr_main_url}/${var.prefix}-frontend:latest"
  task_container_port = 8080
}

## service
module "ecs_frontend_service" {
  source         = "../../modules/ecs/service"
  env            = "${var.env}"
  prefix         = "${var.prefix}"
  owner          = "${var.owner}"
  name           = "frontend"
  cluster_name   = "${module.ecs_cluster.cluster_name}"
  desired_count  = "${var.ecs_frontend_desired_capacity}"
  iam_role       = "${module.ecs_cluster.ecs_iam_role_name}"
  definition_arn = "${module.ecs_frontend_task.task_definition_arn}"
  target_group   = "${module.ecs_cluster.frontend_tg_arn}"
  container_name = "${var.prefix}-ecs-frontend"
  container_port = 8080
}
```
