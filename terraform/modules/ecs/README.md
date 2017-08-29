# ECS Module

## Description
Terraform module that creates an ECS cluster and maanges the ECS Services and Tasks.

## Usage
```
module "ecs" {
  source = "../../modules/ecs"
  env    = "${var.env}"
  prefix = "${var.prefix}"
}
```
