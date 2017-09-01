# ECS Cluster Module Outputs
# DavyJ0nes 2017

output "cluster_name" {
  value = "${aws_ecs_cluster.env.name}"
}

output "cluster_id" {
  value = "${aws_ecs_cluster.env.id}"
}

output "frontend_tg_arn" {
  value = "${aws_alb_target_group.ecs_alb_front_end.arn}"
}

output "frontend_tg_arn_suffix" {
  value = "${aws_alb_target_group.ecs_alb_front_end.arn_suffix}"
}

output "api_tg_arn" {
  value = "${aws_alb_target_group.ecs_alb_api.arn}"
}

output "api_tg_arn_suffix" {
  value = "${aws_alb_target_group.ecs_alb_api.arn_suffix}"
}

output "alb_arn" {
  value = "${aws_alb.ecs_alb.arn_suffix}"
}

output "ecs_iam_role_name" {
  value = "${aws_iam_role.ecs_instance.name}"
}

output "ecs_iam_role_arn" {
  value = "${aws_iam_role.ecs_instance.arn}"
}
