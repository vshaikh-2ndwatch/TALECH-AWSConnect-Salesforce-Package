output "domain_name" {
    value = var.sfAudioRecordingStreamingCloudFrontDistributionCondition ? aws_cloudfront_distribution.audio_recording_streaming_distribution[0].domain_name : ""
}

output "id" {
    value = var.sfAudioRecordingStreamingCloudFrontDistributionCondition ? aws_cloudfront_distribution.audio_recording_streaming_distribution[0].id : null
}