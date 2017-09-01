# Development Stack
# Davy Jones 2017

output "api_ecr_repo_url" {
  value = "${module.api_ecr.ecr_url}"
}

output "frontend_ecr_repo_url" {
  value = "${module.frontend_ecr.ecr_url}"
}
