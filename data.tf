
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy" "secretsmanager_policy" {
  arn = aws_iam_policy.secretsmanager_policy.arn
}

data "aws_iam_policy" "kms_policy" {
  arn = aws_iam_policy.kms_policy.arn
}

data "aws_iam_policy" "cloud_watch_policy" {
  arn = aws_iam_policy.cloud_watch_policy.arn
}

data "aws_iam_policy" "vpc_policy" {
  count = length(aws_iam_policy.vpc_policy)
  arn   = aws_iam_policy.vpc_policy[count.index].arn
}


data "aws_iam_policy_document" "lambda-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda-edge-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "states-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "events-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_role" "lambda_basic_exec" {
  name = aws_iam_role.lambda_basic_exec.name
}

data "aws_iam_role" "lambda_basic_exec_s3read" {
  name = aws_iam_role.lambda_basic_exec_s3read.name
}

data "aws_iam_role" "realtime_queue_metrics" {
  name = aws_iam_role.realtime_queue_metrics.name
}

data "aws_iam_role" "realtime_queue_metrics_loop_job" {
  name = aws_iam_role.realtime_queue_metrics_loop_job.name
}

data "aws_iam_role" "get_transcribe_job_status" {
  name = aws_iam_role.get_transcribe_job_status.name
}

data "aws_iam_role" "submit_transcribe_job" {
  name = aws_iam_role.submit_transcribe_job.name
}

data "aws_iam_role" "process_transcription_result" {
  name = aws_iam_role.process_transcription_result.name
}

data "aws_iam_role" "process_contactlens" {
  name = aws_iam_role.process_contactlens.name
}

data "aws_iam_role" "transcribe_state_machine" {
  name = aws_iam_role.transcribe_state_machine.name
}

data "aws_iam_role" "execute_transcription_state_machine" {
  name = aws_iam_role.execute_transcription_state_machine.name
}

data "aws_iam_role" "ctr_trigger" {
  name = aws_iam_role.ctr_trigger.name
}

data "aws_iam_role" "realtime_queue_metrics_loop_job_state_machine" {
  name = aws_iam_role.realtime_queue_metrics_loop_job_state_machine.name
}

data "aws_iam_role" "realtime_queue_metrics_cron_execution" {
  name = aws_iam_role.realtime_queue_metrics_cron_execution.name
}


data "aws_lambda_function" "realtime_queue_metrics_lambda" {
  function_name = aws_lambda_function.realtime_queue_metrics_lambda.function_name
}

data "aws_lambda_function" "invoke_api_lambda" {
  function_name = aws_lambda_function.invoke_api_lambda.function_name
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

data "aws_lambda_function" "execute_transcription_state_machine_lambda" {
  function_name = aws_lambda_function.execute_transcription_state_machine_lambda.function_name
}

data "aws_lambda_function" "contacttrace_record_lambda" {
  function_name = aws_lambda_function.contacttrace_record_lambda.function_name
}

data "aws_lambda_function" "generate_audio_recording_streaming_url_lambda" {
  count         = length(aws_lambda_function.generate_audio_recording_streaming_url_lambda)
  function_name = aws_lambda_function.generate_audio_recording_streaming_url_lambda[count.index].function_name
}

data "aws_cloudfront_distribution" "audio_recording_streaming_distribution" {
  count = length(aws_cloudfront_distribution.audio_recording_streaming_distribution)
  id    = aws_cloudfront_distribution.audio_recording_streaming_distribution[count.index].id
}

data "aws_sfn_state_machine" "transcribe_state_machine" {
    name = aws_sfn_state_machine.transcribe_state_machine.name
}

data "aws_sfn_state_machine" "realtime_queue_metrics_loop_job_state_machine" {
    name = aws_sfn_state_machine.realtime_queue_metrics_loop_job_state_machine.name
}