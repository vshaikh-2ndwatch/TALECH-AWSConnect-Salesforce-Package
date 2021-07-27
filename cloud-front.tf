resource "aws_cloudfront_distribution" "audio_recording_streaming_distribution" {
  #sfAudioRecordingStreamingCloudFrontDistribution
  count = local.PostcallRecordingImportEnabledCondition ? 1 : 0

  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"] #Note: Added to avoid terraform error.It may not be required parameter
    compress                 = true
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # Managed-CORS-S3Origin
    target_origin_id         = "AudioRecordingStreamingCloudFrontOrigin"
    trusted_signers          = ["self"]
    viewer_protocol_policy   = "redirect-to-https"

  }

  origin {
    domain_name = "${var.ConnectRecordingS3BucketName}.s3.${data.aws_region.current.name}.amazonaws.com"
    origin_id   = "AudioRecordingStreamingCloudFrontOrigin"
    custom_origin_config {
      http_port              = 80  #Note: Added to avoid terraform error.It may not be required parameter
      https_port             = 443 #Note: Added to avoid terraform error.It may not be required parameter
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
    custom_header {
      name  = "Access-Control-Allow-Origin"
      value = var.SalesforceHost
    }
    origin_path = "/connect"
  }
  #Note: Added to avoid terraform error.It may not be required parameter
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  #Note: Added to avoid terraform error.It may not be required parameter
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }



}