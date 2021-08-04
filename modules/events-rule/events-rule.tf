# Cloudwatch Events Rule
resource "aws_cloudwatch_event_target" "step-function-state-machine" {
  rule      = aws_cloudwatch_event_rule.realtime_queue_metrics_cron.name
  target_id = "sfRealTimeQueue"
  arn       = var.realtime_queue_metrics_loop_job_state_machine_arn
  role_arn  = var.realtime_queue_metrics_cron_execution_role_arn
}

resource "aws_cloudwatch_event_rule" "realtime_queue_metrics_cron" {
  name        = "sfRealTimeQueueMetricsCron"
  description = "Executes Step Functions every minute"
  schedule_expression = "rate(1 minute)"
  is_enabled = var.RealtimeReportingImportEnabledCondition ? true : false
}
