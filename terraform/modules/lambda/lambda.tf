# Lambda Module
# DavyJ0nes 2017

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda" {
  filename         = "${var.file}"
  function_name    = "${var.prefix}-${var.env}-${var.name}"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "${var.handler}"
  source_code_hash = "${base64sha256(file("${var.file}"))}"
  runtime          = "${var.runtime}"

  environment {
    variables = {
      URL  = "${var.url}"
      TEXT = "${var.expected_text}"
    }
  }

  tags {
    Name    = "${var.prefix}-${var.env}-${var.name}"
    Owner   = "${var.owner}"
    Service = "${var.name}"
  }
}

resource "aws_cloudwatch_event_rule" "event" {
  name                = "${var.prefix}-${var.env}-${var.name}-cw_trigger"
  schedule_expression = "${var.schedule}"
}

resource "aws_cloudwatch_event_target" "lambda_trigger" {
  rule = "${aws_cloudwatch_event_rule.event.name}"
  arn  = "${aws_lambda_function.lambda.arn}"
}
