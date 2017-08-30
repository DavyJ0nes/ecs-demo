# ECS Cluster Module Outputs
# DavyJ0nes 2017

output "cluster_name" {
  value = "${aws_ecs_cluster.env.name}"
}

output "cluster_id" {
  value = "${aws_ecs_cluster.env.id}"
}
