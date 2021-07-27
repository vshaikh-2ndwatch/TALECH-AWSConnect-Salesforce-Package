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
  LambdaRuntime = "python3.8"
  LambdaSource  = "."

  #Define Conditions
  PostcallRecordingImportEnabledCondition = (var.PostcallRecordingImportEnabled == "True") || (var.PostcallRecordingImportEnabled == "true")
  PostcallTranscribeEnabledCondition      = (var.PostcallTranscribeEnabled == "True") || (var.PostcallTranscribeEnabled == "true")
  PostcallCTRImportEnabledCondition       = (var.PostcallCTRImportEnabled == "True") || (var.PostcallCTRImportEnabled == "true")

  HistoricalReportingImportEnabledCondition = (var.HistoricalReportingImportEnabled == "True") || (var.HistoricalReportingImportEnabled == "true")
  RealtimeReportingImportEnabledCondition   = (var.RealtimeReportingImportEnabled == "True") || (var.RealtimeReportingImportEnabled == "true")
  ContactLensImportEnabledCondition         = (var.ContactLensImportEnabled == "True") || (var.ContactLensImportEnabled == "true")
  PrivateVpcEnabledCondition                = (var.PrivateVpcEnabled == "True") || (var.PrivateVpcEnabled == "true")

  CTREventSourceMappingCondition = local.PostcallRecordingImportEnabledCondition || local.PostcallTranscribeEnabledCondition || local.PostcallCTRImportEnabledCondition

  PostcallTranscribeRecordingImportEnabledCondition = local.PostcallRecordingImportEnabledCondition || local.PostcallTranscribeEnabledCondition


  Managed_Policies_Based_on_VPC = local.PrivateVpcEnabledCondition ? ([data.aws_iam_policy.secretsmanager_policy.arn, data.aws_iam_policy.kms_policy.arn, data.aws_iam_policy.cloud_watch_policy.arn,
  data.aws_iam_policy.vpc_policy[0].arn]) : ([data.aws_iam_policy.secretsmanager_policy.arn, data.aws_iam_policy.kms_policy.arn, data.aws_iam_policy.cloud_watch_policy.arn])

  LambdaSubnetIds        = local.PrivateVpcEnabledCondition ? var.VpcSubnetList : []
  LambdaSecurityGroupIds = local.PrivateVpcEnabledCondition ? var.VpcSecurityGroupList : []

  CloudFront_Distribution_Domain_Name = local.PostcallRecordingImportEnabledCondition ? data.aws_cloudfront_distribution.audio_recording_streaming_distribution[0].domain_name : ""

}