# ECS Module
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
    from_port       = "80"
    to_port         = "80"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]
  }

  ingress {
    from_port       = "443"
    to_port         = "443"
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
  port     = 8081
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  tags {
    Owner       = "${var.owner}"
    Environment = "${var.env}"
    Name        = "${var.prefix}-${var.env}-alb-fe-tg"
    Service     = "FrontEnd"
  }
}

#----------- CREATE ECS ALB JSON JILL TARGET GROUP ----------#

resource "aws_alb_target_group" "ecs_alb_api" {
  name     = "${var.prefix}-${var.env}-alb-api-tg"
  port     = 8082
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

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

#----------- CREATE ECS ALB DEFAULT LISTENER ----------#

resource "aws_alb_listener" "main" {
  load_balancer_arn = "${aws_alb.ecs_alb.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${data.aws_acm_certificate.cert.arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.ecs_alb_front_end.arn}"
    type             = "forward"
  }
}

#----------- CREATE ECS ALB API LISTENER ----------#

resource "aws_alb_listener_rule" "api" {
  listener_arn = "${aws_alb_listener.main.arn}"
  priority     = 100

  action {
    target_group_arn = "${aws_alb_target_group.ecs_alb_api.arn}"
    type             = "forward"
  }

  condition {
    field  = "path-pattern"
    values = ["/v1/data/*"]
  }
}

#---------- CREATE ECS ASG LAUNCH CONFIGURATION ----------#

resource "aws_launch_configuration" "ecs_lc" {
  name_prefix     = "${var.prefix}-${var.env}-ecs"
  image_id        = "${var.ami}"
  instance_type   = "${var.instance_type}"
  key_name        = "${var.key_name}"
  security_groups = ["${aws_security_group.asg.id}"]

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
  name              = "${var.prefix}-${var.env}-ecs-asg"
  max_size          = "${var.max_size}"
  min_size          = "${var.min_size}"
  health_check_type = "ELB"
  enabled_metrics   = ["GroupInServiceInstances", "GroupPendingInstances", "GroupDesiredCapacity", "GroupTerminatingInstances", "GroupTotalInstances"]
  desired_capacity  = "${var.desired_capacity}"

  # force_delete         = true
  launch_configuration = "${aws_launch_configuration.ecs_lc.name}"
  load_balancers       = ["${aws_alb.ecs_alb.id}"]
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