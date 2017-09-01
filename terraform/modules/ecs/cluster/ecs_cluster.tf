# ECS Cluster Module
# DavyJ0nes 2017

#----------- CREATE EMPTY ECS CLUSTER ----------#

resource "aws_ecs_cluster" "env" {
  name = "${var.prefix}-${var.env}-cluster"
}

#----------- SET UP ECS ALB SECURITY GROUP ----------#

resource "aws_security_group" "alb" {
  name        = "${var.prefix}-${var.env}-ecs-alb-sg"
  vpc_id      = "${var.vpc_id}"
  description = "ECS ALB Security Group"

  tags {
    Name  = "${var.prefix}-${var.env}-ecs-alb-sg"
    Owner = "${var.owner}"
  }

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#----------- SET UP ECS ASG SECURITY GROUP ----------#

resource "aws_security_group" "asg" {
  name        = "${var.prefix}-${var.env}-ecs-asg-sg"
  vpc_id      = "${var.vpc_id}"
  description = "ECS ASG Security Group"

  tags {
    Name  = "${var.prefix}-${var.env}-ecs-asg-sg"
    Owner = "${var.owner}"
  }

  ingress {
    from_port       = "0"
    to_port         = "65535"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#---------- CREATE ECS ALB ----------#

resource "aws_alb" "ecs_alb" {
  name            = "${var.prefix}-${var.env}-alb"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = ["${split(",", var.subnets)}"]
  internal        = false

  tags {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    Name        = "${var.prefix}-${var.env}-ecs-alb"
  }
}

#----------- CREATE ECS ALB FRONT END TARGET GROUP ----------#

resource "aws_alb_target_group" "ecs_alb_front_end" {
  name     = "${var.prefix}-${var.env}-alb-fe-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/health"
  }

  tags {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    Name        = "${var.prefix}-${var.env}-alb-fe-tg"
    Service     = "FrontEnd"
  }
}

#----------- CREATE ECS ALB API TARGET GROUP ----------#

resource "aws_alb_target_group" "ecs_alb_api" {
  name     = "${var.prefix}-${var.env}-alb-api-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/health"
  }

  tags {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    Name        = "${var.prefix}-${var.env}-alb-api-tg"
    Service     = "API"
  }
}

#----------- GET ACM TLS CERTIFICATE ----------#

data "aws_acm_certificate" "cert" {
  domain   = "*.${var.domain}"
  statuses = ["ISSUED"]
}

#----------- CREATE ECS ALB DEFAULT HTTP LISTENER ----------#

resource "aws_alb_listener" "http" {
  load_balancer_arn = "${aws_alb.ecs_alb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.ecs_alb_front_end.arn}"
    type             = "forward"
  }

  depends_on = ["aws_alb.ecs_alb"]
}

#----------- CREATE ECS ALB DEFAULT HTTPS LISTENER ----------#

resource "aws_alb_listener" "https" {
  load_balancer_arn = "${aws_alb.ecs_alb.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${data.aws_acm_certificate.cert.arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.ecs_alb_front_end.arn}"
    type             = "forward"
  }

  depends_on = ["aws_alb.ecs_alb"]
}

#----------- CREATE ECS ALB API LISTENER ----------#

resource "aws_alb_listener_rule" "api_https" {
  listener_arn = "${aws_alb_listener.https.arn}"
  priority     = 100

  action {
    target_group_arn = "${aws_alb_target_group.ecs_alb_api.arn}"
    type             = "forward"
  }

  condition {
    field  = "path-pattern"
    values = ["/v1/*"]
  }

  depends_on = ["aws_alb.ecs_alb"]
}

#----------- CREATE ECS ALB API LISTENER ----------#

resource "aws_alb_listener_rule" "api_http" {
  listener_arn = "${aws_alb_listener.http.arn}"
  priority     = 100

  action {
    target_group_arn = "${aws_alb_target_group.ecs_alb_api.arn}"
    type             = "forward"
  }

  condition {
    field  = "path-pattern"
    values = ["/v1/*"]
  }

  depends_on = ["aws_alb.ecs_alb"]
}

#---------- CREATE ECS INSTANCE ROLE ----------#

resource "aws_iam_role" "ecs_instance" {
  name        = "${var.prefix}-${var.env}-ecs_instance-role"
  description = "Owner: ${var.owner}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#---------- CREATE ECS INSTANCE ROLE POLICY ----------#

resource "aws_iam_role_policy" "ecs_instance_policy" {
  name = "${var.prefix}-${var.env}-ecs-policy"
  role = "${aws_iam_role.ecs_instance.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
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

#---------- ECS ROLE POLICY ATTACHMENT ----------#

resource "aws_iam_role_policy_attachment" "ecsInstanceRole" {
  role       = "${aws_iam_role.ecs_instance.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

#---------- ECS INSTANCE PROFILE ----------#

resource "aws_iam_instance_profile" "profile" {
  name = "${var.prefix}-${var.env}-ecs_instance-profile"
  role = "${aws_iam_role.ecs_instance.name}"
}

#---------- CREATE EC2 INSTANCE ROLE ----------#

resource "aws_iam_role" "ec2_instance" {
  name        = "${var.prefix}-${var.env}-ec2_instance-role"
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

#---------- CREATE EC2 INSTANCE ROLE POLICY ----------#

resource "aws_iam_role_policy" "ec2_instance_policy" {
  name = "${var.prefix}-${var.env}-ec2-policy"
  role = "${aws_iam_role.ec2_instance.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
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

#---------- ECS ROLE POLICY ATTACHMENT ----------#

resource "aws_iam_role_policy_attachment" "ec2InstanceRole" {
  role       = "${aws_iam_role.ec2_instance.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

#---------- ECS INSTANCE PROFILE ----------#

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.prefix}-${var.env}-ec2_instance-profile"
  role = "${aws_iam_role.ec2_instance.name}"
}

#---------- CREATE ECS ASG LAUNCH CONFIGURATION ----------#

resource "aws_launch_configuration" "ecs_lc" {
  name_prefix          = "${var.prefix}-${var.env}-ecs"
  image_id             = "${var.ami}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.ec2_profile.name}"
  key_name             = "${var.key_name}"
  security_groups      = ["${aws_security_group.asg.id}"]

  user_data = <<USERDATA
  #!/bin/bash
  echo ECS_CLUSTER=${aws_ecs_cluster.env.name} >> /etc/ecs/ecs.config
USERDATA

  lifecycle {
    create_before_destroy = true
  }
}

#----------- SET UP AUTOSCALING GROUP ----------#

resource "aws_autoscaling_group" "asg" {
  name                 = "${var.prefix}-${var.env}-ecs-asg"
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  health_check_type    = "ELB"
  enabled_metrics      = ["GroupInServiceInstances", "GroupPendingInstances", "GroupDesiredCapacity", "GroupTerminatingInstances", "GroupTotalInstances"]
  desired_capacity     = "${var.desired_capacity}"
  target_group_arns    = ["${aws_alb_target_group.ecs_alb_api.arn}", "${aws_alb_target_group.ecs_alb_front_end.arn}"]
  launch_configuration = "${aws_launch_configuration.ecs_lc.name}"
  vpc_zone_identifier  = ["${split(",", var.subnets)}"]

  depends_on = ["aws_launch_configuration.ecs_lc"]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.prefix}-${var.env}-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = "${var.owner}"
    propagate_at_launch = true
  }
}

#----------- SET UP AUTOSCALING POLICY ----------#

resource "aws_autoscaling_policy" "policy" {
  name                   = "${var.prefix}-${var.env}-asg-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

#----------- SET UP CW METRIC ALARM ----------#

resource "aws_cloudwatch_metric_alarm" "asg-alarm" {
  alarm_name          = "${var.prefix}-${var.env}-asg-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }

  alarm_description = "This Metric Monitors EC2 CPU Utilization"
  alarm_actions     = ["${aws_autoscaling_policy.policy.arn}"]
}
