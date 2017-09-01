# Cloudwatch Module
# Davy Jones
# Cloudreach

#---------- CREATE CLOUDWATCH DASHBOARD ----------#
resource "aws_cloudwatch_dashboard" "dashboard" {
  dashboard_name = "${var.prefix}-${var.env}-ECS-Dashboard"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "text",
            "x": 0,
            "y": 17,
            "width": 24,
            "height": 1,
            "properties": {
                "markdown": "\n# Front End Service\n"
            }
        },
        {
            "type": "text",
            "x": 0,
            "y": 42,
            "width": 24,
            "height": 1,
            "properties": {
                "markdown": "\n# API Service\n"
            }
        },
        {
            "type": "text",
            "x": 0,
            "y": 67,
            "width": 24,
            "height": 1,
            "properties": {
                "markdown": "\n# ALB Metrics\n"
            }
        },
        {
            "type": "text",
            "x": 0,
            "y": 0,
            "width": 24,
            "height": 1,
            "properties": {
                "markdown": "\n# Lambda Health Check\n"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 24,
            "width": 24,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCountPerTarget", "TargetGroup", "${var.api_tg_arn}", "LoadBalancer", "${var.alb_arn}", { "period": 1 } ],
                    [ "...", { "stat": "p99", "period": 1 } ]
                ],
                "region": "${var.region}",
                "title": "Request Count Per Target"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 18,
            "width": 18,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", "${var.api_tg_arn}", "LoadBalancer", "${var.alb_arn}", { "period": 5, "stat": "Average" } ],
                    [ ".", "UnHealthyHostCount", ".", ".", ".", ".", { "period": 5, "stat": "Average" } ]
                ],
                "region": "${var.region}",
                "title": "Host Counts",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 18,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "singleValue",
                "metrics": [
                    [ "AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", "${var.api_tg_arn}", "LoadBalancer", "${var.alb_arn}", { "stat": "Minimum" } ]
                ],
                "region": "${var.region}"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 11,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ECS", "CPUUtilization", "ClusterName", "${var.prefix}-${var.env}-cluster" ],
                    [ ".", "MemoryUtilization", ".", ".", { "yAxis": "right" } ],
                    [ ".", "CPUUtilization", ".", ".", { "stat": "p99" } ],
                    [ ".", "MemoryUtilization", ".", ".", { "yAxis": "right", "stat": "p99" } ]
                ],
                "region": "${var.region}",
                "title": "CPU and Memory Utilisation"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 11,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ECS", "CPUReservation", "ClusterName", "${var.prefix}-${var.env}-cluster", { "stat": "p99" } ],
                    [ ".", "MemoryReservation", ".", ".", { "stat": "p99", "yAxis": "right" } ],
                    [ ".", "CPUReservation", ".", ".", { "stat": "Average" } ],
                    [ ".", "MemoryReservation", ".", ".", { "stat": "Average", "yAxis": "right" } ]
                ],
                "region": "${var.region}",
                "title": "CPU and Memory Reservation",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 8,
            "width": 6,
            "height": 3,
            "properties": {
                "view": "singleValue",
                "metrics": [
                    [ "AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", "${var.prefix}-${var.env}-ecs-asg", { "period": 60 } ]
                ],
                "region": "${var.region}",
                "period": 300,
                "title": "Running Count"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 8,
            "width": 6,
            "height": 3,
            "properties": {
                "view": "singleValue",
                "metrics": [
                    [ "AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName", "${var.prefix}-${var.env}-ecs-asg" ]
                ],
                "region": "${var.region}",
                "period": 300,
                "title": "Desired Count"
            }
        },
        {
            "type": "metric",
            "x": 18,
            "y": 8,
            "width": 3,
            "height": 3,
            "properties": {
                "view": "singleValue",
                "metrics": [
                    [ "AWS/AutoScaling", "GroupPendingInstances", "AutoScalingGroupName", "${var.prefix}-${var.env}-app-asg" ]
                ],
                "region": "${var.region}",
                "period": 300,
                "title": "Pending Count"
            }
        },
        {
            "type": "metric",
            "x": 21,
            "y": 8,
            "width": 3,
            "height": 3,
            "properties": {
                "view": "singleValue",
                "metrics": [
                    [ "AWS/AutoScaling", "GroupTerminatingInstances", "AutoScalingGroupName", "${var.prefix}-${var.env}-ecs-asg" ]
                ],
                "region": "${var.region}",
                "period": 300,
                "title": "Terminating Count"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 8,
            "width": 6,
            "height": 3,
            "properties": {
                "view": "singleValue",
                "metrics": [
                    [ "AWS/AutoScaling", "GroupTotalInstances", "AutoScalingGroupName", "${var.prefix}-${var.env}-ecs-asg" ]
                ],
                "region": "${var.region}",
                "period": 300,
                "title": "Total Count"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 43,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "singleValue",
                "metrics": [
                    [ "AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", "${var.frontend_tg_arn}", "LoadBalancer", "${var.alb_arn}", { "stat": "Minimum" } ]
                ],
                "region": "${var.region}",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 43,
            "width": 18,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", "${var.frontend_tg_arn}", "LoadBalancer", "${var.alb_arn}", { "period": 5, "stat": "Average" } ],
                    [ ".", "UnHealthyHostCount", ".", ".", ".", ".", { "period": 5, "stat": "Average" } ]
                ],
                "region": "${var.region}",
                "title": "Host Counts",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 36,
            "width": 24,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", "${var.api_tg_arn}", "LoadBalancer", "${var.alb_arn}", { "period": 900, "stat": "Average" } ],
                    [ "...", { "period": 900, "stat": "p99" } ]
                ],
                "region": "${var.region}",
                "title": "Reponse Time / 15min",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 49,
            "width": 24,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCountPerTarget", "TargetGroup", "${var.frontend_tg_arn}", "LoadBalancer", "${var.alb_arn}", { "period": 30, "stat": "p99" } ],
                    [ "...", { "period": 30, "stat": "Average" } ]
                ],
                "region": "${var.region}",
                "title": "Request Count Per Target",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 61,
            "width": 24,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", "${var.frontend_tg_arn}", "LoadBalancer", "${var.alb_arn}" ],
                    [ "...", { "stat": "p99" } ]
                ],
                "region": "${var.region}",
                "title": "Reponse Time / 15min",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 68,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "ActiveConnectionCount", "LoadBalancer", "${var.alb_arn}" ],
                    [ ".", "NewConnectionCount", ".", "." ]
                ],
                "region": "${var.region}",
                "title": "Connection Counts"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 68,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "ClientTLSNegotiationErrorCount", "LoadBalancer", "${var.alb_arn}" ],
                    [ ".", "TargetConnectionErrorCount", ".", "." ]
                ],
                "region": "${var.region}",
                "title": "Connection Error Counts",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 74,
            "width": 24,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", "${var.alb_arn}" ],
                    [ ".", "HTTPCode_Target_2XX_Count", ".", "." ],
                    [ ".", "HTTPCode_Target_3XX_Count", ".", "." ]
                ],
                "region": "${var.region}",
                "title": "Target HTTP Code Counts",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 80,
            "width": 24,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", "${var.alb_arn}" ],
                    [ ".", "HTTPCode_ELB_4XX_Count", ".", "." ]
                ],
                "region": "${var.region}",
                "title": "ALB HTTP Code Counts",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 30,
            "width": 24,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", "${var.api_tg_arn}", "LoadBalancer", "${var.alb_arn}", { "period": 900, "stat": "Average" } ],
                    [ "...", { "period": 900, "stat": "p99" } ]
                ],
                "region": "${var.region}",
                "title": "Reponse Time / 15min",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 55,
            "width": 24,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCountPerTarget", "TargetGroup", "${var.frontend_tg_arn}", "LoadBalancer", "${var.alb_arn}", { "period": 30, "stat": "p99" } ],
                    [ "...", { "period": 30, "stat": "Average" } ]
                ],
                "region": "${var.region}",
                "title": "Request Count Per Target",
                "period": 300
            }
        },
        {
            "type": "text",
            "x": 0,
            "y": 7,
            "width": 24,
            "height": 1,
            "properties": {
                "markdown": "\n# ECS Cluster\n"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 1,
            "width": 24,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/Lambda", "Errors", "FunctionName", "${var.lambda_name}", "Resource", "${var.lambda_name}" ],
                    [ ".", "Invocations", ".", ".", ".", "." ],
                    [ ".", "Duration", ".", ".", ".", ".", { "yAxis": "right" } ]
                ],
                "region": "${var.region}"
            }
        }
    ]
}
EOF
}
