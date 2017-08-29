# ECR Module
# DavyJ0nes 2017

resource "aws_ecr_repository" "env" {
  name = "${var.prefix}-${var.env}-ecr"
}

resource "aws_ecr_repository_policy" "ecrpolicy" {
  repository = "${aws_ecr_repository.env.name}"

  policy = <<POLICY
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "${var.prefix}-${var.env}-ecr-policy",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
            ]
        }
    ]
}
POLICY
}
