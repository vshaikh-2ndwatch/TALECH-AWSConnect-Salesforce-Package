# Cloudwatch Events Rule
resource "aws_cloudwatch_event_target" "step-function-state-machine" {
  rule      = aws_cloudwatch_event_rule.realtime_queue_metrics_cron.name
  target_id = "StateMachine-sfRealTimeQueue"
  arn       = data.aws_sfn_state_machine.realtime_queue_metrics_loop_job_state_machine.arn
  role_arn  = data.aws_iam_role.realtime_queue_metrics_cron_execution.arn
}

resource "aws_cloudwatch_event_rule" "realtime_queue_metrics_cron" {
  name        = "sfRealTimeQueueMetricsCron"
  description = "Executes Step Functions every minute"
  schedule_expression = "rate(1 minute)"
  is_enabled = local.RealtimeReportingImportEnabledCondition ? true : false
}
