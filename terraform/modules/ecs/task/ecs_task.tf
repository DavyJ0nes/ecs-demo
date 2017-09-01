# ECS Task Module
# DavyJ0nes 2017

#----------- CREATE TASK DEFINITION TEMPLATE FILE ----------#

data "template_file" "task_definition" {
  template = "${file("${path.module}/task_definition.json")}"

  vars = {
    task_name      = "${var.task_name}"
    image_url      = "${var.task_image_url}"
    container_port = "${var.task_container_port}"
  }
}

#----------- SET UP TASK DEFINITION ----------#

resource "aws_ecs_task_definition" "task" {
  family                = "${var.prefix}-${var.env}-${var.service}-task"
  container_definitions = "${data.template_file.task_definition.rendered}"
  network_mode          = "bridge"
}
