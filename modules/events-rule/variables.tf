variable "realtime_queue_metrics_loop_job_state_machine_arn" {
    type = string
    description = "ARN of the RealTime Queue Metrics Loop Job State Machine"
}

variable "realtime_queue_metrics_cron_execution_role_arn" {
    type = string
    description = "ARN of the Realtime Queue Metrics Cron Execution Role"
}

variable "RealtimeReportingImportEnabledCondition" {
    type = string
    description = "Set to false if importing Realtime Reporting into Salesforce should not be enabled."
}
