data aws_caller_identity current {}

data aws_s3_bucket cloudfront_logs {
  bucket = "${data.aws_caller_identity.current.account_id}-tv-cloudfront-logs"
}
