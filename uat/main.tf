#local variables
locals {

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

  subnet_ids        = local.PrivateVpcEnabledCondition ? var.VpcSubnetList : []
  security_group_ids = local.PrivateVpcEnabledCondition ? var.VpcSecurityGroupList : []

  # IAM Roles ARNs
  lambda_basic_exec_role_arn = "arn:aws:iam::${var.account_id}:role/sfLambdaBasicExec"
  execute_aws_service_role_arn = "arn:aws:iam::${var.account_id}:role/sfExecuteAWSServiceRole"
  sig4_request_to_s3_role_arn = "arn:aws:iam::${var.account_id}:role/sfSig4RequestToS3Role"
  lambda_basic_exec_s3read_role_arn = "arn:aws:iam::${var.account_id}:role/sfLambdaBasicExecWithS3Read"
  realtime_queue_metrics_role_arn = "arn:aws:iam::${var.account_id}:role/sfRealTimeQueueMetricsRole"
  realtime_queue_metrics_loop_job_role_arn = "arn:aws:iam::${var.account_id}:role/sfRealTimeQueueMetricsLoopJobRole"
  get_transcribe_job_status_role_arn = "arn:aws:iam::${var.account_id}:role/sfGetTranscribeJobStatusRole"
  submit_transcribe_job_role_arn = "arn:aws:iam::${var.account_id}:role/sfSubmitTranscribeJobRole"
  execute_transcription_state_machine_role_arn = "arn:aws:iam::${var.account_id}:role/sfExecuteTranscriptionStateMachineRole"
  ctr_trigger_role_arn = "arn:aws:iam::${var.account_id}:role/sfCTRTriggerRole"
  process_transcription_result_role_arn = "arn:aws:iam::${var.account_id}:role/sfProcessTranscriptionResultRole"
  process_contactlens_role_arn = "arn:aws:iam::${var.account_id}:role/sfProcessContactLensRole"
  realtime_queue_metrics_loop_job_state_machine_role_arn = "arn:aws:iam::${var.account_id}:role/sfRealTimeQueueMetricsLoopJobStateMachineRole"
  transcribe_state_machine_role_arn = "arn:aws:iam::${var.account_id}:role/sfTranscribeStateMachineRole"
  realtime_queue_metrics_cron_execution_role_arn = "arn:aws:iam::${var.account_id}:role/service-role/sfRealTimeQueueMetricsCronExecutionRole"

  transcribe_state_machine_name = "sfTranscribeStateMachine"
  realtime_queue_metrics_loop_job_state_machine_name = "sfRealTimeQueueMetricsLoopJobStateMachine"

}
  
  #Modules

  #CloudFront Distribution Module
  module "ac_salesforce_cloudfront" {
    source = "../modules/cloud-front"
    region = var.region
    sfAudioRecordingStreamingCloudFrontDistributionCondition = local.sfAudioRecordingStreamingCloudFrontDistributionCondition
    ConnectRecordingS3BucketName = var.ConnectRecordingS3BucketName
    SalesforceHost = var.SalesforceHost
    PostcallRecordingImportEnabledCondition = local.PostcallRecordingImportEnabledCondition
  }

  #Lambda Module
  module "ac_salesforce_lambdas" {
    source = "../modules/lambda"

    lambda_layer_zip = "../lambda_functions/lambda_layers.zip"
    runtime = var.runtime

    CTREventSourceMappingCondition = local.CTREventSourceMappingCondition
    sfAudioRecordingStreamingCloudFrontDistributionCondition = local.sfAudioRecordingStreamingCloudFrontDistributionCondition
    PostcallRecordingImportEnabledCondition = local.PostcallRecordingImportEnabledCondition

    CTRKinesisARN = var.CTRKinesisARN
    CTREventSourceMappingMaximumRetryAttempts = var.CTREventSourceMappingMaximumRetryAttempts
    subnet_ids = local.subnet_ids
    security_group_ids = local.security_group_ids
    SalesforceHost = var.SalesforceHost
    SalesforceProduction = var.SalesforceProduction
    SalesforceUsername = var.SalesforceUsername
    SalesforceVersion = var.SalesforceVersion
    SalesforceAdapterNamespace = var.SalesforceAdapterNamespace
    SalesforceCredentialsSecretsManagerARN = var.SalesforceCredentialsSecretsManagerARN
    LambdaLoggingLevel = var.LambdaLoggingLevel
    ConnectRecordingS3BucketName = var.ConnectRecordingS3BucketName
    TranscribeOutputS3BucketName = var.TranscribeOutputS3BucketName
    ContactLensImportEnabled = var.ContactLensImportEnabled
    TranscriptionJobCheckWaitTime = var.TranscriptionJobCheckWaitTime
    PostcallCTRImportEnabled = var.PostcallCTRImportEnabled
    PostcallRecordingImportEnabled = var.PostcallRecordingImportEnabled
    PostcallTranscribeEnabled = var.PostcallTranscribeEnabled
    AmazonConnectInstanceId = var.AmazonConnectInstanceId
    AmazonConnectQueueMaxRecords = var.AmazonConnectQueueMaxRecords
    AmazonConnectQueueMetricsMaxRecords = var.AmazonConnectQueueMetricsMaxRecords

    lambda_basic_exec_role_arn = local.lambda_basic_exec_role_arn
    execute_aws_service_role_arn = local.execute_aws_service_role_arn
    sig4_request_to_s3_role_arn = local.sig4_request_to_s3_role_arn
    realtime_queue_metrics_role_arn = local.realtime_queue_metrics_role_arn
    realtime_queue_metrics_loop_job_role_arn = local.realtime_queue_metrics_loop_job_role_arn
    lambda_basic_exec_s3read_role_arn = local.lambda_basic_exec_s3read_role_arn
    get_transcribe_job_status_role_arn = local.get_transcribe_job_status_role_arn
    submit_transcribe_job_role_arn = local.submit_transcribe_job_role_arn
    process_transcription_result_role_arn = local.process_transcription_result_role_arn
    process_contactlens_role_arn = local.process_contactlens_role_arn
    execute_transcription_state_machine_role_arn = local.execute_transcription_state_machine_role_arn
    ctr_trigger_role_arn=local.ctr_trigger_role_arn

    audio_recording_streaming_distribution_id = module.ac_salesforce_cloudfront.id
    audio_recording_streaming_distribution_domain_name = module.ac_salesforce_cloudfront.domain_name
    transcribe_state_machine_arn = "arn:aws:states:${var.region}:${var.account_id}:stateMachine:${local.transcribe_state_machine_name}"
  }

  #Step Functions State Machine Module
  module "ac_salesforce_step_functions_state_machine" {
    source = "../modules/step-functions"
    transcribe_state_machine_role_arn = local.transcribe_state_machine_role_arn
    submit_transcibe_job_lambda_arn = module.ac_salesforce_lambdas.submit_transcibe_job_lambda_arn
    get_transcibe_job_status_lambda_arn = module.ac_salesforce_lambdas.get_transcibe_job_status_lambda_arn
    process_transcription_result_lambda_arn = module.ac_salesforce_lambdas.process_transcription_result_lambda_arn
    realtime_queue_metrics_loop_job_state_machine_role_arn = local.realtime_queue_metrics_loop_job_state_machine_role_arn
    realtime_queue_metrics_loop_job_lambda_arn = module.ac_salesforce_lambdas.realtime_queue_metrics_loop_job_lambda_arn
  }

  #Event Rule Module
  module "ac_salesforce_events_rule" {
    source = "../modules/events-rule"
    realtime_queue_metrics_loop_job_state_machine_arn = "arn:aws:states:${var.region}:${var.account_id}:stateMachine:${local.realtime_queue_metrics_loop_job_state_machine_name}"
    realtime_queue_metrics_cron_execution_role_arn = local.realtime_queue_metrics_cron_execution_role_arn
    RealtimeReportingImportEnabledCondition = local.RealtimeReportingImportEnabledCondition
  }
