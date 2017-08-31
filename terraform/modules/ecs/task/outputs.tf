# ECS Task Module Outputs
# DavyJ0nes 2017

output "task_definition_arn" {
  value = "${aws_ecs_task_definition.task.arn}"
}
