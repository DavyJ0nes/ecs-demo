# Cloudwatch Module Variables
# Davy Jones
# Cloudreach

variable "env" {
  description = "The Environment name of the VPC"
}

variable "prefix" {
  description = "Naming prefix to use"
}

variable "owner" {
  description = "Identifying name of person who owns resource"
}

variable "region" {
  description = "The region that the dashboard should be hosted in"
}

variable "alb_arn" {
  description = "The ARN suffix of the ALB"
}

variable "api_tg_arn" {
  description = "The ARN of the API Target Group"
}

variable "frontend_tg_arn" {
  description = "The ARN of the Frontend Target Group"
}

variable "lambda_name" {
  description = "The name of the testing lambda for the Cloudwatch dashboard"
}
