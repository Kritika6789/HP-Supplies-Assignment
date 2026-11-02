provider "aws" {
  region = var.region
}

module "s3_bucket" {
  source = "../../modules/s3-bucket"

  bucket = var.bucket
  policy = var.configure_policy == true ? data.aws_iam_policy_document.policy.json : null

  lifecycle_rules = var.lifecycle_rule_id == "" ? [] : [{
    id      = var.lifecycle_rule_id
    enabled = var.lifecycle_config_enabled
    prefix  = var.lifecycle_rule_prefix

    expiration = {
      days = var.lifecycle_expiration_days
    }

    transition = [{
      days          = var.lifecycle_transition_days
      storage_class = var.lifecycle_transition_storage_class
    }]

    noncurrent_version_expiration = {
      days = var.lifecycle_expiration_days
    }
  }]

  server_side_encryption_configuration = var.configure_server_side_encryption == false ? [] : [{
    kms_master_key_id = aws_kms_key.encrypt_key.key_id
    sse_algorithm     = "aws:kms"
  }]

  enable_logging = var.enable_logging
}

resource "aws_kms_key" "encrypt_key" {
  description = "Key used to encrypt objects in S3"
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.bucket}",
      "arn:aws:s3:::${var.bucket}/*",
    ]

    principals {
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
      type        = "AWS"
    }
  }
}

resource "aws_sqs_queue" "queue" {
  name = var.sqsname

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:${var.sqsname}",
      "Condition": {
        "ArnEquals": { "aws:SourceArn": "${module.s3_bucket.arn}" }
      }
    }
  ]
}
POLICY
}

module "s3_sqs_notification" {
  source        = "../../modules/s3-bucket-notification-sqs"
  bucket_name   = var.bucket
  sqs_arn       = aws_sqs_queue.queue.arn
  s3_event      = var.s3_event
  filter_suffix = var.filter_suffix
}
