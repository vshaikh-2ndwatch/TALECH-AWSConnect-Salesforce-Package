terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = "~> 3.50.0"
    }
  }
}

#local variables
locals {

  LambdaTimeout = 6
  LambdaRuntime = "python3.7"

  #Define Conditions
  
  PostcallRecordingImportEnabledCondition = (var.PostcallRecordingImportEnabled == "True") || (var.PostcallRecordingImportEnabled == "true")
  PostcallTranscribeEnabledCondition      = (var.PostcallTranscribeEnabled == "True") || (var.PostcallTranscribeEnabled == "true")
  PostcallCTRImportEnabledCondition       = (var.PostcallCTRImportEnabled == "True") || (var.PostcallCTRImportEnabled == "true")

  CTRKinesisARNHasValue = (var.CTRKinesisARN != "")
  ConnectRecordingS3BucketNameHasValue = (var.ConnectRecordingS3BucketName != "")
  
  PrivateVpcEnabledCondition                = (var.PrivateVpcEnabled == "True") || (var.PrivateVpcEnabled == "true")
  RealtimeReportingImportEnabledCondition   = (var.RealtimeReportingImportEnabled == "True") || (var.RealtimeReportingImportEnabled == "true")
  sfAudioRecordingStreamingCloudFrontDistributionCondition = local.PostcallRecordingImportEnabledCondition && local.ConnectRecordingS3BucketNameHasValue

  CTREventSourceMappingCondition = (local.CTRKinesisARNHasValue) && (local.PostcallRecordingImportEnabledCondition 
                                        || local.PostcallTranscribeEnabledCondition || local.PostcallCTRImportEnabledCondition)

  LambdaSubnetIds        = local.PrivateVpcEnabledCondition ? var.VpcSubnetList : []
  LambdaSecurityGroupIds = local.PrivateVpcEnabledCondition ? var.VpcSecurityGroupList : []

  CloudFront_Distribution_Domain_Name = local.PostcallRecordingImportEnabledCondition ? data.aws_cloudfront_distribution.audio_recording_streaming_distribution[0].domain_name : ""

  lambda_layer_zip = "./lambda_functions/lambda_layers.zip"

  //Hardcoded ARNs
  lambda_basic_exec_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/sfLambdaBasicExec"
  execute_aws_service_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/sfExecuteAWSServiceRole"
  sig4_request_to_s3_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/sfSig4RequestToS3Role"
  lambda_basic_exec_s3read_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/sfLambdaBasicExecWithS3Read"
  realtime_queue_metrics_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/sfRealTimeQueueMetricsRole"
  realtime_queue_metrics_loop_job_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/sfRealTimeQueueMetricsLoopJobRole"
  get_transcribe_job_status_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/sfGetTranscribeJobStatusRole"
  submit_transcribe_job_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/sfSubmitTranscribeJobRole"
  execute_transcription_state_machine_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/sfExecuteTranscriptionStateMachineRole"
  ctr_trigger_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/sfCTRTriggerRole"
  process_transcription_result_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/sfProcessTranscriptionResultRole"
  process_contactlens_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/sfProcessContactLensRole"
  realtime_queue_metrics_loop_job_state_machine_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/sfRealTimeQueueMetricsLoopJobStateMachineRole"
  transcribe_state_machine_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/sfTranscribeStateMachineRole"
  realtime_queue_metrics_cron_execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/sfRealTimeQueueMetricsCronExecutionRole"
}