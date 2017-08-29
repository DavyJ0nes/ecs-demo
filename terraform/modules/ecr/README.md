# ECR Module

## Description
Terraform moudle that creates an Elastic Container Repository to hold Docker Images that will be used with the Elastic Container Service.

Creates the repository as well as the policy to allow access to relevant bits with ECR.

## Usage
```
module "ecr" {
  source = "../../modules/ecr"
  env    = "${var.env}"
  prefix = "${var.prefix}"
}
```
