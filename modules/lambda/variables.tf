#AWS Account and Lambda variables

variable "lambda_layer_zip" {
  type        = string
}

variable "runtime" {
  type        = string
  description = "coding language in which lambda is written"
}  

#Salesforce related variables

variable "SalesforceProduction" {
  type        = string
  description = "True for Production Environment, False for Sandbox"
}

variable "SalesforceVersion" {
  type        = string
  description = "To find the Salesforce Edition and API Version please visit https://help.salesforce.com/articleView?id=000199268&type=1"
}

variable "SalesforceCredentialsSecretsManagerARN" {
  type        = string
  description = "Enter the ARN for the Salesforce Credentials Secret in AWS Secrets Manager. This field is required."
}

variable "SalesforceAdapterNamespace" {
  type        = string
  description = "This is the namespace for CTI Adapter managed package. The default value is [amazonconnect]. If a non-managed package is used, leave this field blank."
}

variable "SalesforceHost" {
  type        = string
  description = "Your Salesforce Host. Please make sure the host url starts with \"https\"."
}

variable "SalesforceUsername" {
  type        = string
  description = "The username of a valid Salesforce API account for your environment. For example, user@domain.com"
}

#Amazon Connect related variables
variable "AmazonConnectInstanceId" {
  type        = string
  description = "Enter Amazon Connect Instance Id, the string after the last / in your Amazon Connect instance ARN (aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee). Not required if RealtimeReportingImportEnabled is set to false."
}

variable "AmazonConnectQueueMaxRecords" {
  type        = number
  description = "Enter record set size for list queue query. Max is 100."
}

variable "AmazonConnectQueueMetricsMaxRecords" {
  type        = number
  description = "Enter record set size for queue metrics query. Max is 100."
}

variable "LambdaLoggingLevel" {
  type        = string
  description = "Logging level for Lambda functions. Set one of the following DEBUG | INFO | WARNING | ERROR | CRITICAL"
}

# Other variables

variable "ConnectRecordingS3BucketName" {
  type        = string
  description = "This is the S3 bucket where Amazon Connect stores call recordings. Please refer to http://docs.aws.amazon.com/connect/latest/adminguide/amazon-connect-instance.html#datastorage for details on how retrieve the S3 bucket associated with your Amazon Connect instance. Not required if both PostcallRecordingImportEnabled and PostcallTranscribeEnabled set to false."
}

variable "TranscribeOutputS3BucketName" {
  type        = string
  description = "This is the S3 bucket where Amazon Transcribe stores the output. If you don't specify an encryption key, the output of the transcription job is encrypted with the default Amazon S3 key (SSE-S3).Not required if both PostcallRecordingImportEnabled and PostcallTranscribeEnabled set to false."
}

variable "TranscriptionJobCheckWaitTime" {
  type        = number
  description = "Time between transcription job checks"
}

variable "CTRKinesisARN" {
  type        = string
  description = "Enter Kinesis Stream ARN for CTR. Not required if PostcallCTRImportEnabled, PostcallRecordingImportEnabled and PostcallTranscribeEnabled all set to false"
}

variable "CTREventSourceMappingMaximumRetryAttempts" {
  type        = number
  description = "Maximum retry attempts on failure for lambdas triggered by Kinesis Events"
}

variable "PostcallRecordingImportEnabled" {
  type        = string
  description = "Set to false if importing call recordings into Salesforce should not be enabled on the package level. See installation guide for setup details."
}

variable "PostcallTranscribeEnabled" {
  type        = string
  description = "Set to false if post-call transcription should not be enabled on the package level. See installation guide for setup details."
}

variable "PostcallCTRImportEnabled" {
  type        = string
  description = "Set to false if importing CTRs into Salesforce should not be enabled on the package level."
}

variable "ContactLensImportEnabled" {
  type        = string
  description = "Set to false if importing Contact Lens into Salesforce should not be enabled."
}

variable "security_group_ids" {
  type        = list(string)
  description = "The list of SecurityGroupIds for the Virtual Private Cloud (VPC). Not required if PrivateVpcEnabled is set to false."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The list of Subnets for the Virtual Private Cloud (VPC). Not required if PrivateVpcEnabled is set to false."
}

variable "CTREventSourceMappingCondition" {
    type = string
}

variable "sfAudioRecordingStreamingCloudFrontDistributionCondition" {
    type = string
}

variable "PostcallRecordingImportEnabledCondition" {
    type = string
}

#IAM Roles and ARNs variables
variable "lambda_basic_exec_role_arn" {
    type = string
}
variable "execute_aws_service_role_arn" {
    type = string
}
variable "sig4_request_to_s3_role_arn" {
    type = string
}
variable "realtime_queue_metrics_role_arn" {
    type = string
}
variable "realtime_queue_metrics_loop_job_role_arn" {
    type = string
}
variable "lambda_basic_exec_s3read_role_arn" {
    type = string
}
variable "get_transcribe_job_status_role_arn" {
    type = string
}
variable "submit_transcribe_job_role_arn" {
    type = string
}
variable "process_transcription_result_role_arn" {
    type = string
}
variable "process_contactlens_role_arn" {
    type = string
}
variable "execute_transcription_state_machine_role_arn" {
    type = string
}
variable "ctr_trigger_role_arn" {
    type = string
}
variable "audio_recording_streaming_distribution_id" {
    type = string
}
variable "transcribe_state_machine_arn" {
    type = string
}
variable "audio_recording_streaming_distribution_domain_name" {
    type = string
}