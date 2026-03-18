# Builder step 2: enable_monitoring
# Completely optional — only included when the caller sets
# enable_monitoring = true

variable "instance_id"        {}
variable "enable_monitoring"  { default = false }

resource "aws_cloudwatch_metric_alarm" "cpu" {
  count               = var.enable_monitoring ? 1 : 0  # ← optional step

  alarm_name          = "cpu-high-${var.instance_id}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    InstanceId = var.instance_id
  }
}

output "alarm_arn" {
  value = var.enable_monitoring ? aws_cloudwatch_metric_alarm.cpu[0].arn : null
}