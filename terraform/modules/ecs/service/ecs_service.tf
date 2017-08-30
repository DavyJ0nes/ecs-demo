# ECS Service Module
# DavyJ0nes 2017

#----------- SET UP TASK DEFINITION ----------#

resource "aws_ecs_task_definition" "task" {
  family                = "${var.prefix}-${var.env}-${var.name}-task"
  container_definitions = "${var.definition}"
  network_mode          = "bridge"
}

#---------- CREATE ECS SERVICE ROLE ----------#

resource "aws_iam_role" "ecs_service" {
  name        = "${var.prefix}-${var.env}-ecs_service-role"
  description = "Owner: ${var.owner}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#---------- CREATE ECS INSTANCE ROLE POLICY ----------#

resource "aws_iam_role_policy" "ecs_service" {
  name = "${var.prefix}-${var.env}-ecs_service-policy"
  role = "${aws_iam_role.ecs_service.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

#----------- SET UP SERVICE ----------#
resource "aws_ecs_service" "service" {
  name            = "${var.prefix}-${var.env}-${var.name}-service"
  cluster         = "${var.cluster_name}"
  task_definition = "${aws_ecs_task_definition.task.arn}"
  desired_count   = "${var.desired_count}"
  iam_role        = "${aws_iam_role.role.arn}"
  depends_on      = ["aws_iam_role_policy.policy"]

  placement_strategy {
    type = "spread"
  }

  load_balancer {
    target_group_arn = "${var.target_group}"
    container_name   = "${var.container_name}"
    container_port   = "${var.container_port}"
  }
}
