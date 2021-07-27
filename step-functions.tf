# Transcribe State Machine
resource "aws_sfn_state_machine" "transcribe_state_machine" {
  name     = "sfTranscribeStateMachine"
  role_arn = data.aws_iam_role.transcribe_state_machine.arn

  definition = <<EOF
    {
        "Comment": "A state machine that submits a Job to transcribe audio",
        "StartAt": "Submit Transcription Job",
        "States": {
            "Submit Transcription Job": {
                "Type": "Task",
                "Resource": "${data.aws_lambda_function.submit_transcibe_job_lambda.arn}",
                "ResultPath": "$.TranscriptionJob",
                    "Next": "Wait X Seconds",
                    "Retry": [
                        {
                            "ErrorEquals": [
                                "States.ALL"
                            ],
                            "IntervalSeconds": 20,
                            "MaxAttempts": 3,
                            "BackoffRate": 2
                        }
                    ]
            },
            "Wait X Seconds": {
                "Type": "Wait",
                "SecondsPath": "$.wait_time",
                "Next": "Get Transcription Job Status"
            },
            "Get Transcription Job Status": {
                "Type": "Task",
                "Resource": "${data.aws_lambda_function.get_transcibe_job_status_lambda.arn}",
                "Next": "Job Complete?",
                "InputPath": "$.TranscriptionJob",
                "ResultPath": "$.TranscriptionJob",
                "Retry": [
                    {
                        "ErrorEquals": [
                            "States.ALL"
                        ],
                        "IntervalSeconds": 20,
                        "MaxAttempts": 3,
                        "BackoffRate": 2
                    }
                ]
            },
            "Job Complete?": {
                "Type": "Choice",
                "Choices": [
                    {
                        "Variable": "$.TranscriptionJob.TranscriptionJobStatus",
                        "StringEquals": "FAILED",
                        "Next": "Job Failed"
                    },
                    {
                        "Variable": "$.TranscriptionJob.TranscriptionJobStatus",
                        "StringEquals": "COMPLETED",
                        "Next": "Process Transcription Result"
                    }
                ],
                "Default": "Wait X Seconds"
            },
            "Job Failed": {
                "Type": "Fail",
                "Cause": "Transcription job Failed",
                "Error": "Transcription job FAILED"
            },
            "Process Transcription Result": {
                "Type": "Task",
                "Resource": "${data.aws_lambda_function.process_transcription_result_lambda.arn}", 
                "InputPath": "$",
                "End": true,
                "Retry": [
                    {
                        "ErrorEquals": [
                            "States.ALL"
                        ],
                        "IntervalSeconds": 20,
                        "MaxAttempts": 3,
                        "BackoffRate": 2
                    }
                ]
            }
        }
    }
EOF
}

# Real Time Queue Metrics Loop Job State Machine
resource "aws_sfn_state_machine" "realtime_queue_metrics_loop_job_state_machine" {
  name     = "sfRealTimeQueueMetricsLoopJobStateMachine"
  role_arn = data.aws_iam_role.realtime_queue_metrics_loop_job_state_machine.arn

  definition = <<EOF
    {
        "Comment": "Invoke Real time Queue Metrics Lambda function every 15 seconds",
        "StartAt": "ConfigureCount",
        "States": {
            "ConfigureCount": {
                "Type": "Pass",
                "Result": {
                    "index": 0,
                    "count": 4
                },
                "ResultPath": "$.iterator",
                "Next": "Iterator"
            },
            "Iterator": {
                "Type": "Task",
                "Resource": "${data.aws_lambda_function.realtime_queue_metrics_loop_job_lambda.arn}", 
                "ResultPath": "$.iterator",
                "Next": "IsCountReached"
            },
            "IsCountReached": {
                "Type": "Choice",
                "Choices": [
                    {
                        "Variable": "$.iterator.continue",
                        "BooleanEquals": true,
                        "Next": "Wait"
                    }
                ],
                "Default": "Done"
            },
            "Wait": {
                "Type": "Wait",
                "Seconds": 15,
                "Next": "Iterator"
            },
            "Done": {
                "Type": "Pass",
                "End": true
            }
        }
    }
EOF
}

