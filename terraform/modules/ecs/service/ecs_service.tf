# ECS Service Module
# DavyJ0nes 2017

#----------- SET UP SERVICE ----------#
resource "aws_ecs_service" "service" {
  name            = "${var.prefix}-${var.env}-${var.name}-service"
  cluster         = "${var.cluster_name}"
  task_definition = "${var.definition_arn}"
  desired_count   = "${var.desired_count}"
  iam_role        = "${var.iam_role}"

  load_balancer {
    target_group_arn = "${var.target_group}"
    container_name   = "${var.container_name}"
    container_port   = "${var.container_port}"
  }
}
