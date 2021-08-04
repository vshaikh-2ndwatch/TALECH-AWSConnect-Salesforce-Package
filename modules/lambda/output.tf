output "submit_transcibe_job_lambda_arn" {
    value = aws_lambda_function.submit_transcibe_job_lambda.arn
}

output "get_transcibe_job_status_lambda_arn" {
    value = aws_lambda_function.get_transcibe_job_status_lambda.arn
}

output "process_transcription_result_lambda_arn" {
    value = aws_lambda_function.process_transcription_result_lambda.arn
}

output "realtime_queue_metrics_loop_job_lambda_arn" {
    value = aws_lambda_function.realtime_queue_metrics_loop_job_lambda.arn
}