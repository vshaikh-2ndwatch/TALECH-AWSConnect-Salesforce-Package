#Lambda layer
resource "aws_lambda_layer_version" "sf_lambda_layer" {
  layer_name          = "sfLambdaLayer"
  description         = "Salesforce Lambda function external dependencies"
  filename            = var.lambda_layer_zip
  source_code_hash    = "${filebase64sha256(var.lambda_layer_zip)}"
  compatible_runtimes = [var.runtime]
}


#Lambda Event Source Mapping
resource "aws_lambda_event_source_mapping" "ctr_event_source_mapping" {
  count = var.CTREventSourceMappingCondition ? 1 : 0
  event_source_arn  = var.CTRKinesisARN
  function_name     = aws_lambda_function.ctr_trigger_lambda.arn
  starting_position = "LATEST"
  batch_size        = 100
  maximum_retry_attempts = var.CTREventSourceMappingMaximumRetryAttempts
}

#Lambdas

#Invoke API Lambda
data "archive_file" "invoke_api_lambda_package" {
  type        = "zip"
  source_file = "../lambda_functions/sfInvokeAPI.py"
  output_path = "/tmp/invoke_api_lambda_package_zip.zip"
}

resource "aws_lambda_function" "invoke_api_lambda" {
  function_name    = "sfInvokeAPI"
  filename         = data.archive_file.invoke_api_lambda_package.output_path
  source_code_hash = data.archive_file.invoke_api_lambda_package.output_base64sha256
  handler          = "sfInvokeAPI.lambda_handler"
  runtime          = var.runtime
  layers           = [aws_lambda_layer_version.sf_lambda_layer.arn]
  role             = var.lambda_basic_exec_role_arn

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = {
      SF_HOST                            = var.SalesforceHost
      SF_PRODUCTION                      = var.SalesforceProduction
      SF_USERNAME                        = var.SalesforceUsername
      SF_VERSION                         = var.SalesforceVersion
      SF_ADAPTER_NAMESPACE               = var.SalesforceAdapterNamespace
      SF_CREDENTIALS_SECRETS_MANAGER_ARN = var.SalesforceCredentialsSecretsManagerARN
      LOGGING_LEVEL                      = var.LambdaLoggingLevel
    }
  }
}

#Execute AWS Service Lambda
data "archive_file" "execute_aws_service_lambda_package" {
  type        = "zip"
  source_file = "../lambda_functions/sfExecuteAWSService.py"
  output_path = "/tmp/execute_aws_service_lambda_package_zip.zip"
}

resource "aws_lambda_function" "execute_aws_service_lambda" {
  function_name    = "sfExecuteAWSService"
  filename         = data.archive_file.execute_aws_service_lambda_package.output_path
  source_code_hash = data.archive_file.execute_aws_service_lambda_package.output_base64sha256
  handler          = "sfExecuteAWSService.lambda_handler"
  runtime          = var.runtime
  role             = var.execute_aws_service_role_arn
  timeout          = 10
  
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = {
      GENERATE_AUDIO_RECORDING_LAMBDA   = var.sfAudioRecordingStreamingCloudFrontDistributionCondition ? aws_lambda_function.generate_audio_recording_streaming_url_lambda[0].arn : null
      CLOUDFORMATION_STACK_ID           = ""
      CLOUDFORMATION_STACK_NAME         = ""
      LOGGING_LEVEL                     = var.LambdaLoggingLevel
      CLOUDFRONT_DISTRIBUTION_ID        = var.sfAudioRecordingStreamingCloudFrontDistributionCondition ? var.audio_recording_streaming_distribution_id : null
      RECORDING_BUCKET_NAME             = var.ConnectRecordingS3BucketName
      SF_ADAPTER_NAMESPACE              = var.SalesforceAdapterNamespace
      SF_HOST                           = var.SalesforceHost
      SIG4_LAMBDA_ROLE_ARN              = var.PostcallRecordingImportEnabledCondition ? var.sig4_request_to_s3_role_arn : null
    }
  }
}

# RealTime Queue Metrics Lambda
data "archive_file" "realtime_queue_metrics_lambda_package" {
  type        = "zip"
  source_file = "../lambda_functions/sfRealTimeQueueMetrics.py"
  output_path = "/tmp/realtime_queue_metrics_lambda_package_zip.zip"
}

resource "aws_lambda_function" "realtime_queue_metrics_lambda" {
  function_name    = "sfRealTimeQueueMetrics"
  filename         = data.archive_file.realtime_queue_metrics_lambda_package.output_path
  source_code_hash = data.archive_file.realtime_queue_metrics_lambda_package.output_base64sha256
  handler          = "sfRealTimeQueueMetrics.lambda_handler"
  runtime          = var.runtime
  layers           = [aws_lambda_layer_version.sf_lambda_layer.arn]
  role             = var.realtime_queue_metrics_role_arn
  timeout          = 900

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = {
      SF_HOST                                = var.SalesforceHost
      SF_PRODUCTION                          = var.SalesforceProduction
      SF_USERNAME                            = var.SalesforceUsername
      SF_VERSION                             = var.SalesforceVersion
      SF_ADAPTER_NAMESPACE                   = var.SalesforceAdapterNamespace
      SF_CREDENTIALS_SECRETS_MANAGER_ARN     = var.SalesforceCredentialsSecretsManagerARN
      LOGGING_LEVEL                          = var.LambdaLoggingLevel
      AMAZON_CONNECT_INSTANCE_ID             = var.AmazonConnectInstanceId
      AMAZON_CONNECT_QUEUE_MAX_RESULT        = var.AmazonConnectQueueMaxRecords
      AMAZON_CONNECT_QUEUEMETRICS_MAX_RESULT = var.AmazonConnectQueueMetricsMaxRecords
    }
  }
}

# RealTime Queue Metrics Loop Job Lambda
data "archive_file" "realtime_queue_metrics_loop_job_lambda_package" {
  type        = "zip"
  source_file = "../lambda_functions/sfRealTimeQueueMetricsLoopJob.py"
  output_path = "/tmp/realtime_queue_metrics_loop_job_lambda_package_zip.zip"
}

resource "aws_lambda_function" "realtime_queue_metrics_loop_job_lambda" {
  function_name    = "sfRealTimeQueueMetricsLoopJob"
  filename         = data.archive_file.realtime_queue_metrics_loop_job_lambda_package.output_path
  source_code_hash = data.archive_file.realtime_queue_metrics_loop_job_lambda_package.output_base64sha256
  handler          = "sfRealTimeQueueMetricsLoopJob.lambda_handler"
  runtime          = var.runtime
  layers           = [aws_lambda_layer_version.sf_lambda_layer.arn]
  role             = var.realtime_queue_metrics_loop_job_role_arn
  timeout          = 10

  environment {
    variables = {
      SFDC_REALTIME_QUEUE_METRICS_LAMBDA = aws_lambda_function.realtime_queue_metrics_lambda.arn
      LOGGING_LEVEL                      = var.LambdaLoggingLevel
    }
  }
}


# Contact Trace Record Lambda
data "archive_file" "contacttrace_record_lambda_package" {
  type        = "zip"
  source_file = "../lambda_functions/sfContactTraceRecord.py"
  output_path = "/tmp/contacttrace_record_lambda_package_zip.zip"
}

resource "aws_lambda_function" "contacttrace_record_lambda" {
  function_name    = "sfContactTraceRecord"
  filename         = data.archive_file.contacttrace_record_lambda_package.output_path
  source_code_hash = data.archive_file.contacttrace_record_lambda_package.output_base64sha256
  handler          = "sfContactTraceRecord.lambda_handler"
  runtime          = var.runtime
  layers           = [aws_lambda_layer_version.sf_lambda_layer.arn]
  role             = var.lambda_basic_exec_role_arn
  timeout          = 30

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = {
      SF_HOST                            = var.SalesforceHost
      SF_PRODUCTION                      = var.SalesforceProduction
      SF_USERNAME                        = var.SalesforceUsername
      SF_VERSION                         = var.SalesforceVersion
      SF_ADAPTER_NAMESPACE               = var.SalesforceAdapterNamespace
      SF_CREDENTIALS_SECRETS_MANAGER_ARN = var.SalesforceCredentialsSecretsManagerARN
      LOGGING_LEVEL                      = var.LambdaLoggingLevel
    }
  }
}

# Interval Agent Lambda
data "archive_file" "interval_agent_lambda_package" {
  type        = "zip"
  source_file = "../lambda_functions/sfIntervalAgent.py"
  output_path = "/tmp/interval_agent_lambda_package_zip.zip"
}

resource "aws_lambda_function" "interval_agent_lambda" {
  function_name    = "sfIntervalAgent"
  filename         = data.archive_file.interval_agent_lambda_package.output_path
  source_code_hash = data.archive_file.interval_agent_lambda_package.output_base64sha256
  handler          = "sfIntervalAgent.lambda_handler"
  runtime          = var.runtime
  layers           = [aws_lambda_layer_version.sf_lambda_layer.arn]
  role             = var.lambda_basic_exec_s3read_role_arn
  timeout          = 60

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = {
      SF_HOST                            = var.SalesforceHost
      SF_PRODUCTION                      = var.SalesforceProduction
      SF_USERNAME                        = var.SalesforceUsername
      SF_VERSION                         = var.SalesforceVersion
      SF_ADAPTER_NAMESPACE               = var.SalesforceAdapterNamespace
      SF_CREDENTIALS_SECRETS_MANAGER_ARN = var.SalesforceCredentialsSecretsManagerARN
      LOGGING_LEVEL                      = var.LambdaLoggingLevel
    }
  }
}

# Interval Queue Lambda
data "archive_file" "interval_queue_lambda_package" {
  type        = "zip"
  source_file = "../lambda_functions/sfIntervalQueue.py"
  output_path = "/tmp/interval_queue_lambda_package_zip.zip"
}

resource "aws_lambda_function" "interval_queue_lambda" {
  function_name    = "sfIntervalQueue"
  filename         = data.archive_file.interval_queue_lambda_package.output_path
  source_code_hash = data.archive_file.interval_queue_lambda_package.output_base64sha256
  handler          = "sfIntervalQueue.lambda_handler"
  runtime          = var.runtime
  layers           = [aws_lambda_layer_version.sf_lambda_layer.arn]
  role             = var.lambda_basic_exec_s3read_role_arn
  timeout          = 60

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = {
      SF_HOST                            = var.SalesforceHost
      SF_PRODUCTION                      = var.SalesforceProduction
      SF_USERNAME                        = var.SalesforceUsername
      SF_VERSION                         = var.SalesforceVersion
      SF_ADAPTER_NAMESPACE               = var.SalesforceAdapterNamespace
      SF_CREDENTIALS_SECRETS_MANAGER_ARN = var.SalesforceCredentialsSecretsManagerARN
      LOGGING_LEVEL                      = var.LambdaLoggingLevel
    }
  }
}

# Get Transcribe Job Status Lambda
data "archive_file" "get_transcibe_job_status_lambda_package" {
  type        = "zip"
  source_file = "../lambda_functions/sfGetTranscribeJobStatus.py"
  output_path = "/tmp/get_transcibe_job_status_lambda_package_zip.zip"
}

resource "aws_lambda_function" "get_transcibe_job_status_lambda" {
  function_name    = "sfGetTranscribeJobStatus"
  filename         = data.archive_file.get_transcibe_job_status_lambda_package.output_path
  source_code_hash = data.archive_file.get_transcibe_job_status_lambda_package.output_base64sha256
  handler          = "sfGetTranscribeJobStatus.lambda_handler"
  runtime          = var.runtime
  layers           = [aws_lambda_layer_version.sf_lambda_layer.arn]
  role             = var.get_transcribe_job_status_role_arn
  timeout          = 10

  environment {
    variables = {
      LOGGING_LEVEL = var.LambdaLoggingLevel
    }
  }
}

# Submit Transcribe Job Lambda
data "archive_file" "submit_transcibe_job_lambda_package" {
  type        = "zip"
  source_file = "../lambda_functions/sfSubmitTranscribeJob.py"
  output_path = "/tmp/submit_transcibe_job_lambda_package_zip.zip"
}

resource "aws_lambda_function" "submit_transcibe_job_lambda" {
  function_name    = "sfSubmitTranscribeJob"
  filename         = data.archive_file.submit_transcibe_job_lambda_package.output_path
  source_code_hash = data.archive_file.submit_transcibe_job_lambda_package.output_base64sha256
  handler          = "sfSubmitTranscribeJob.lambda_handler"
  runtime          = var.runtime
  layers           = [aws_lambda_layer_version.sf_lambda_layer.arn]
  role             = var.submit_transcribe_job_role_arn
  timeout          = 10

  environment {
    variables = {
      LOGGING_LEVEL = var.LambdaLoggingLevel
    }
  }
}

# Process Transcription Result Lambda
data "archive_file" "process_transcription_result_lambda_package" {
  type        = "zip"
  source_file = "../lambda_functions/sfProcessTranscriptionResult.py"
  output_path = "/tmp/process_transcription_result_lambda_package_zip.zip"
}

resource "aws_lambda_function" "process_transcription_result_lambda" {
  function_name    = "sfProcessTranscriptionResult"
  filename         = data.archive_file.process_transcription_result_lambda_package.output_path
  source_code_hash = data.archive_file.process_transcription_result_lambda_package.output_base64sha256
  handler          = "sfProcessTranscriptionResult.lambda_handler"
  runtime          = var.runtime
  layers           = [aws_lambda_layer_version.sf_lambda_layer.arn]
  role             = var.process_transcription_result_role_arn
  timeout          = 60

  environment {
    variables = {
      SFDC_INVOKE_API_LAMBDA = aws_lambda_function.invoke_api_lambda.arn
      SF_ADAPTER_NAMESPACE   = var.SalesforceAdapterNamespace
      LOGGING_LEVEL          = var.LambdaLoggingLevel
    }
  }
}

# Process Contact Lens Lambda
data "archive_file" "process_contact_lens_lambda_package" {
  type        = "zip"
  source_file = "../lambda_functions/sfProcessContactLens.py"
  output_path = "/tmp/process_contact_lens_lambda_package_zip.zip"
}

resource "aws_lambda_function" "process_contact_lens_lambda" {
  function_name    = "sfProcessContactLens"
  filename         = data.archive_file.process_contact_lens_lambda_package.output_path
  source_code_hash = data.archive_file.process_contact_lens_lambda_package.output_base64sha256
  handler          = "sfProcessContactLens.lambda_handler"
  runtime          = var.runtime
  layers           = [aws_lambda_layer_version.sf_lambda_layer.arn]
  role             = var.process_contactlens_role_arn
  timeout          = 60

  environment {
    variables = {
      SFDC_INVOKE_API_LAMBDA      = aws_lambda_function.invoke_api_lambda.arn
      SF_ADAPTER_NAMESPACE        = var.SalesforceAdapterNamespace
      LOGGING_LEVEL               = var.LambdaLoggingLevel
      TRANSCRIPTS_DESTINATION     = var.TranscribeOutputS3BucketName
      CONTACT_LENS_IMPORT_ENABLED = var.ContactLensImportEnabled
      AMAZON_CONNECT_INSTANCE_ID  = var.AmazonConnectInstanceId
    }
  }
}

# Generate Audio Recording Streaming URL Lambda
data "archive_file" "generate_audio_recording_streaming_url_lambda_package" {
  type        = "zip"
  source_file = "../lambda_functions/sfGenerateAudioRecordingStreamingURL.py"
  output_path = "/tmp/generate_audio_recording_streaming_url_lambda_package_zip.zip"
}

resource "aws_lambda_function" "generate_audio_recording_streaming_url_lambda" {
  count            = var.sfAudioRecordingStreamingCloudFrontDistributionCondition ? 1 : 0
  function_name    = "sfGenerateAudioRecordingStreamingURL"
  filename         = data.archive_file.generate_audio_recording_streaming_url_lambda_package.output_path
  source_code_hash = data.archive_file.generate_audio_recording_streaming_url_lambda_package.output_base64sha256
  handler          = "sfGenerateAudioRecordingStreamingURL.lambda_handler"
  runtime          = var.runtime
  layers           = [aws_lambda_layer_version.sf_lambda_layer.arn]
  role             = var.lambda_basic_exec_role_arn
  timeout          = 10

  environment {
    variables = {
      SF_HOST                             = var.SalesforceHost
      SF_CREDENTIALS_SECRETS_MANAGER_ARN  = var.SalesforceCredentialsSecretsManagerARN
      LOGGING_LEVEL                       = var.LambdaLoggingLevel
      CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME = var.audio_recording_streaming_distribution_domain_name
    }
  }
}

# Execute Transcription State Machine Lambda
data "archive_file" "execute_transcription_state_machine_lambda_package" {
  type        = "zip"
  source_file = "../lambda_functions/sfExecuteTranscriptionStateMachine.py"
  output_path = "/tmp/execute_transcription_state_machine_lambda_package_zip.zip"
}

resource "aws_lambda_function" "execute_transcription_state_machine_lambda" {
  function_name    = "sfExecuteTranscriptionStateMachine"
  filename         = data.archive_file.execute_transcription_state_machine_lambda_package.output_path
  source_code_hash = data.archive_file.execute_transcription_state_machine_lambda_package.output_base64sha256
  handler          = "sfExecuteTranscriptionStateMachine.lambda_handler"
  runtime          = var.runtime
  layers           = [aws_lambda_layer_version.sf_lambda_layer.arn]
  role             = var.execute_transcription_state_machine_role_arn
  timeout          = 120

  environment {
    variables = {
        MEDIA_FORMAT                        = "wav"
        TRANSCRIBE_STATE_MACHINE_ARN        = var.transcribe_state_machine_arn
        WAIT_TIME                           = var.TranscriptionJobCheckWaitTime
        TRANSCRIPTS_DESTINATION             = var.TranscribeOutputS3BucketName
        TRANSCRIPTS_DESTINATION_KMS         = ""
        SFDC_INVOKE_API_LAMBDA              = aws_lambda_function.invoke_api_lambda.arn
        SF_ADAPTER_NAMESPACE                = var.SalesforceAdapterNamespace
        LOGGING_LEVEL                       = var.LambdaLoggingLevel
     }
  }
}

# CTR Trigger Lambda
data "archive_file" "ctr_trigger_lambda_package" {
  type        = "zip"
  source_file = "../lambda_functions/sfCTRTrigger.py"
  output_path = "/tmp/ctr_trigger_lambda_package_zip.zip"
}

resource "aws_lambda_function" "ctr_trigger_lambda" {
  function_name    = "sfCTRTrigger"
  filename         = data.archive_file.ctr_trigger_lambda_package.output_path
  source_code_hash = data.archive_file.ctr_trigger_lambda_package.output_base64sha256
  handler          = "sfCTRTrigger.lambda_handler"
  runtime          = var.runtime
  layers           = [aws_lambda_layer_version.sf_lambda_layer.arn]
  role             = var.ctr_trigger_role_arn
  timeout          = 20

  environment {
    variables = {
        EXECUTE_TRANSCRIPTION_STATE_MACHINE_LAMBDA  = aws_lambda_function.execute_transcription_state_machine_lambda.arn
        EXECUTE_CTR_IMPORT_LAMBDA                   = aws_lambda_function.contacttrace_record_lambda.arn
        POSTCALL_CTR_IMPORT_ENABLED                 = var.PostcallCTRImportEnabled
        POSTCALL_RECORDING_IMPORT_ENABLED           = var.PostcallRecordingImportEnabled
        POSTCALL_TRANSCRIBE_ENABLED                 = var.PostcallTranscribeEnabled
        LOGGING_LEVEL                               = var.LambdaLoggingLevel
     }
  }
}
