variable "transcribe_state_machine_role_arn" {
    type = string
}
variable "submit_transcibe_job_lambda_arn" {
    type = string
}
variable "get_transcibe_job_status_lambda_arn" {
    type = string
}
variable "process_transcription_result_lambda_arn" {
    type = string
}
variable "realtime_queue_metrics_loop_job_state_machine_role_arn" {
    type = string
}
variable "realtime_queue_metrics_loop_job_lambda_arn" {
    type = string
}