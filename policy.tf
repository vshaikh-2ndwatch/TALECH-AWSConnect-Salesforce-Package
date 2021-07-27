#IAM Policies

resource "aws_iam_policy" "secretsmanager_policy" {
  name        = "SecretsManagerManagedPolicy"
  path        = "/"
  description = "IAM Policy for Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
        ]
        Effect   = "Allow"
        Resource = var.SalesforceCredentialsSecretsManagerARN
      },
    ]
  })
}

resource "aws_iam_policy" "kms_policy" {
  name        = "KMSManagedPolicy"
  path        = "/"
  description = "IAM Policy for KMS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:decrypt",
          "kms:generatedatakey",
        ]
        Effect   = "Allow"
        Resource = var.SalesforceCredentialsKMSKeyARN
      },
    ]
  })
}

resource "aws_iam_policy" "cloud_watch_policy" {
  name        = "CloudWatchManagedPolicy"
  path        = "/"
  description = "IAM Policy for Cloud Watch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
    ]
  })
}

resource "aws_iam_policy" "vpc_policy" {
  count       = local.PrivateVpcEnabledCondition ? 1 : 0
  name        = "VpcManagedPolicy"
  path        = "/"
  description = "IAM Policy for VPC"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

#Note : Not used anywhere currently.
resource "aws_iam_policy" "invoke_generate_audio_recording_streaming_url_policy" {
  count       = local.PostcallRecordingImportEnabledCondition ? 1 : 0
  name        = "invokeSfGenerateAudioRecordingStreamingURLPolicy"
  path        = "/"
  description = "IAM Policy for Invoking sfGenerateAudioRecordingStreamingURL lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction"
        ]
        Effect   = "Allow"
        Resource = "${data.aws_lambda_function.generate_audio_recording_streaming_url_lambda[0].arn}"
      },
    ]
  })
}