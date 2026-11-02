provider "aws" {
  region = var.region
}

data "aws_partition" "current" {}

resource "aws_s3_bucket" "inventory_destination" {
  count = var.configure_inventory && var.inventory_destination_bucket_arn == "" ? 1 : 0

  bucket        = "${var.bucket}-inventory"
  force_destroy = true
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

    abort_incomplete_multipart_upload = {
      days_after_initiation = var.lifecycle_abort_incomplete_multipart_upload_days
    }
  }]

  server_side_encryption_configuration = var.configure_server_side_encryption == false ? [] : [{
    bucket_key_enabled = true
    kms_master_key_id  = aws_kms_key.encrypt_key.key_id
    sse_algorithm      = "aws:kms"
  }]

  inventory_configurations = var.configure_inventory ? {
    daily-inventory = {
      included_object_versions = "Current"
      schedule_frequency       = "Daily"
      destination = {
        bucket_arn = var.inventory_destination_bucket_arn == "" ? aws_s3_bucket.inventory_destination[0].arn : var.inventory_destination_bucket_arn
        format     = "CSV"
      }
    }
  } : {}

  enable_logging   = var.enable_logging
  object_ownership = "BucketOwnerEnforced"
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
      "arn:${data.aws_partition.current.partition}:s3:::${var.bucket}",
      "arn:${data.aws_partition.current.partition}:s3:::${var.bucket}/*",
    ]

    principals {
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${var.account_id}:root"]
      type        = "AWS"
    }
  }

}
