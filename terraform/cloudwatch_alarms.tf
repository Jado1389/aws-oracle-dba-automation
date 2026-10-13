resource "aws_cloudwatch_metric_alarm" "oracle_cpu_high" {
  alarm_name          = "oracle-dba-high-cpu"
  alarm_description   = "CPU usage exceeds 80 percent"
  namespace           = "OracleDBA/Lab"
  metric_name         = "CPUUsage"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = data.aws_instance.oracle_26ai.id
  }
}

resource "aws_cloudwatch_metric_alarm" "oracle_memory_high" {
  alarm_name          = "oracle-dba-high-memory"
  alarm_description   = "Memory usage exceeds 80 percent"
  namespace           = "OracleDBA/Lab"
  metric_name         = "MemoryUsage"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = data.aws_instance.oracle_26ai.id
  }
}

resource "aws_cloudwatch_metric_alarm" "oracle_disk_high" {
  alarm_name          = "oracle-dba-high-disk"
  alarm_description   = "Disk usage exceeds 80 percent"
  namespace           = "OracleDBA/Lab"
  metric_name         = "DiskUsage"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = data.aws_instance.oracle_26ai.id
  }
}
