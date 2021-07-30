data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_sfn_state_machine" "transcribe_state_machine" {
    name = aws_sfn_state_machine.transcribe_state_machine.name
}
data "aws_sfn_state_machine" "realtime_queue_metrics_loop_job_state_machine" {
    name = aws_sfn_state_machine.realtime_queue_metrics_loop_job_state_machine.name
}

data "aws_cloudfront_distribution" "audio_recording_streaming_distribution" {
  count = length(aws_cloudfront_distribution.audio_recording_streaming_distribution)
  id    = aws_cloudfront_distribution.audio_recording_streaming_distribution[count.index].id
}

data "aws_lambda_function" "submit_transcibe_job_lambda" {
  function_name = aws_lambda_function.submit_transcibe_job_lambda.function_name
}

data "aws_lambda_function" "get_transcibe_job_status_lambda" {
  function_name = aws_lambda_function.get_transcibe_job_status_lambda.function_name
}

data "aws_lambda_function" "process_transcription_result_lambda" {
  function_name = aws_lambda_function.process_transcription_result_lambda.function_name
}

data "aws_lambda_function" "realtime_queue_metrics_loop_job_lambda" {
  function_name = aws_lambda_function.realtime_queue_metrics_loop_job_lambda.function_name
}