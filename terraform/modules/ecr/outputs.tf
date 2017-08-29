# ECR Module
# DavyJ0nes 2017

output "ecr_url" {
  value = "${aws_ecr_repository.env.repository_url}"
}

output "ecr_arn" {
  value = "${aws_ecr_repository.env.arn}"
}

output "ecr_id" {
  value = "${aws_ecr_repository.env.id}"
}
