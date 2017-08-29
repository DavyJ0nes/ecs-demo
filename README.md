# ECS Demo

## Description
This is a collection of demo Golang, dockerised web applications that are deployed using [AWS ECS](https://aws.amazon.com/ecs/getting-started) behind an Application Load Balancer that is set up for [Content Based Routing](http://docs.aws.amazon.com/elasticloadbalancing/latest/application/tutorial-load-balancer-routing.html).

They are super basic and lightweight and their only purpose is to be used for demoing how to use ECS with an Application Load Balancer and Content/Path based routing.

## How to deploy
<< TO BE COMPLETED >>

## How to test
<< TO BE COMPLETED >>

## Repo Structure
This repo is broken up in two parts; the apps and the infrastructure provisioning.

The apps are simple microservices that are coded in Golang and built as Docker images.

The infrastructure provisioning is done using [Terraform](https://www.terraform.io). Currently I just have the one stack (dev) but this can be exapanded on to create other environments, such as prod, canary etc.


```
├── README.md
├── apps
│   ├── bill
│   │   ├── Dockerfile
│   │   ├── Makefile
│   │   ├── bill
│   │   └── main.go
│   ├── fred
│   │   ├── Dockerfile
│   │   ├── Makefile
│   │   ├── fred
│   │   └── main.go
│   ├── json_jill
│   │   ├── Dockerfile
│   │   ├── Makefile
│   │   └── main.go
│   └── steve
│       ├── Dockerfile
│       ├── Makefile
│       └── main.go
└── terraform
    ├── env
    │   └── dev
    │       ├── dev.example.tfvars
    │       ├── dev.tf
    │       ├── outputs.tf
    │       └── variables.tf
    └── modules
        ├── ecr
        │   ├── README.md
        │   ├── ecr.tf
        │   ├── outputs.tf
        │   └── variables.tf
        ├── ecs
        │   ├── README.md
        │   ├── ecs.tf
        │   ├── outputs.tf
        │   └── variables.tf
        └── vpc
            ├── README.md
            ├── outputs.tf
            ├── variables.tf
            └── vpc.tf
```

# LICENSE
MIT
