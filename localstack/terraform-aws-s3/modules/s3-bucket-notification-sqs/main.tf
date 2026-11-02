resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.bucket_name

  queue {
    queue_arn     = var.sqs_arn
    events        = var.s3_event
    filter_prefix = var.filter_prefix
    filter_suffix = var.filter_suffix
  }
}
