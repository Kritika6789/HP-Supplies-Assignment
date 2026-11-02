locals {
  access_logs_bucket = "${var.bucket}-access-logs"
}

resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket
  force_destroy = var.force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  count  = var.object_ownership == "BucketOwnerEnforced" ? 0 : 1
  bucket = aws_s3_bucket.bucket.id
  acl    = var.acl

  depends_on = [
    aws_s3_bucket_public_access_block.acl_block,
    aws_s3_bucket_ownership_controls.bucket,
  ]
}

resource "aws_s3_bucket_logging" "bucket_logging" {
  count = var.enable_logging ? 1 : 0

  bucket = aws_s3_bucket.bucket.id

  target_bucket = aws_s3_bucket.access_log_bucket[0].id
  target_prefix = "logs/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_server_side_encryption" {
  count = length(var.server_side_encryption_configuration) > 0 ? 1 : 0

  bucket = aws_s3_bucket.bucket.bucket

  dynamic "rule" {
    for_each = var.server_side_encryption_configuration
    content {
      bucket_key_enabled = lookup(rule.value, "bucket_key_enabled", null)
      apply_server_side_encryption_by_default {
        sse_algorithm     = lookup(rule.value, "sse_algorithm", null)
        kms_master_key_id = lookup(rule.value, "kms_master_key_id", null)
      }
    }
  }
}

# static website hosting
resource "aws_s3_bucket_website_configuration" "bucket_website_config" {
  count = length(keys(var.website_configuration)) > 0 ? 1 : 0

  bucket = aws_s3_bucket.bucket.bucket

  # The splat operator [*] when applied to a non-list value:
  # will produce an empty list if object is null,
  # otherwise will produce a single-element list containing the value.
  dynamic "index_document" {
    for_each = lookup(var.website_configuration, "index_document", null)[*]
    content {
      suffix = index_document.value
    }
  }

  dynamic "error_document" {
    for_each = lookup(var.website_configuration, "error_document", null)[*]
    content {
      key = error_document.value
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = lookup(var.website_configuration, "redirect_all_requests_to", null)[*]
    content {
      host_name = redirect_all_requests_to.value["host_name"]
      protocol  = redirect_all_requests_to.value["protocol"]
    }
  }
}

# CORS rules for cdn-s3
resource "aws_s3_bucket_cors_configuration" "bucket_cors_config" {
  count = length(var.cors_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.bucket.bucket

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers = lookup(cors_rule.value, "allowed_headers", ["*"])
      allowed_methods = lookup(cors_rule.value, "allowed_methods", ["GET"])
      allowed_origins = lookup(cors_rule.value, "allowed_origins", [])
      expose_headers  = lookup(cors_rule.value, "expose_headers", ["ETag"])
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", 3600)
    }
  }
}

resource "aws_s3_bucket_inventory" "bucket_inventory" {
  for_each = local.inventory_configurations_normalized

  bucket                   = aws_s3_bucket.bucket.id
  name                     = each.key
  enabled                  = each.value.enabled
  included_object_versions = each.value.included_object_versions
  optional_fields          = each.value.optional_fields

  schedule {
    frequency = each.value.schedule_frequency
  }

  destination {
    bucket {
      bucket_arn = each.value.bucket_arn
      format     = each.value.format
      account_id = each.value.account_id
      prefix     = each.value.prefix

      dynamic "encryption" {
        for_each = each.value.encryption == null ? [] : [each.value.encryption]

        content {
          dynamic "sse_kms" {
            for_each = each.value.sse_kms_key_id == null ? [] : [each.value.sse_kms_key_id]

            content {
              key_id = sse_kms.value
            }
          }

          dynamic "sse_s3" {
            for_each = each.value.sse_s3 ? [1] : []

            content {}
          }
        }
      }
    }
  }

  dynamic "filter" {
    for_each = each.value.filter_prefix == null ? [] : [each.value.filter_prefix]

    content {
      prefix = filter.value
    }
  }
}

resource "aws_s3_bucket_policy" "inventory_destination_bucket_policy" {
  for_each = local.inventory_configurations_normalized

  bucket = each.value.bucket_name
  policy = data.aws_iam_policy_document.inventory_destination_bucket_policy[each.key].json
}

resource "aws_s3_bucket_public_access_block" "acl_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = local.private_access
  block_public_policy     = local.private_access
  ignore_public_acls      = local.private_access
  restrict_public_buckets = local.private_access
}

resource "aws_s3_bucket_policy" "policy" {
  count = var.enforce_tls || var.policy != null ? 1 : 0

  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.policy.json

  # depends_on needed because of known terraform issue: 
  # https://github.com/terraform-providers/terraform-provider-aws/issues/7628
  depends_on = [aws_s3_bucket_public_access_block.acl_block]
}

resource "aws_s3_bucket" "access_log_bucket" {
  count = var.enable_logging ? 1 : 0

  bucket        = local.access_logs_bucket
  force_destroy = var.access_log_bucket_force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_log_bucket_server_side_encryption" {
  count = var.enable_logging && length(var.access_log_bucket_server_side_encryption_configuration) > 0 ? 1 : 0

  bucket = aws_s3_bucket.access_log_bucket[0].bucket

  dynamic "rule" {
    for_each = var.access_log_bucket_server_side_encryption_configuration
    content {
      bucket_key_enabled = lookup(rule.value, "bucket_key_enabled", null)
      apply_server_side_encryption_by_default {
        sse_algorithm     = lookup(rule.value, "sse_algorithm", null)
        kms_master_key_id = lookup(rule.value, "kms_master_key_id", null)
      }
    }
  }
}

resource "aws_s3_bucket_acl" "access_log_bucket_acl" {
  count = var.enable_logging ? 1 : 0

  bucket = aws_s3_bucket.access_log_bucket[0].id
  acl    = "log-delivery-write"

  depends_on = [
    aws_s3_bucket_ownership_controls.access_log_bucket,
  ]
}

resource "aws_s3_bucket_ownership_controls" "access_log_bucket" {
  count = var.enable_logging ? 1 : 0

  bucket = aws_s3_bucket.access_log_bucket[0].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }

  # depends_on needed because of known terraform issue:
  # https://github.com/terraform-providers/terraform-provider-aws/issues/7628
  depends_on = [aws_s3_bucket_policy.access_log_bucket_policy]
}

resource "aws_s3_bucket_policy" "access_log_bucket_policy" {
  count = var.access_log_bucket_policy == null ? 0 : 1

  bucket = aws_s3_bucket.access_log_bucket[0].id
  policy = var.access_log_bucket_policy
}

resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    object_ownership = var.object_ownership
  }

  # depends_on needed because of known terraform issue:
  # https://github.com/terraform-providers/terraform-provider-aws/issues/7628
  depends_on = [aws_s3_bucket_policy.policy]
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      filter {
        prefix = rule.value.prefix
      }

      # Max 1 block - abort_incomplete_multipart_upload
      dynamic "abort_incomplete_multipart_upload" {
        for_each = length(keys(lookup(rule.value, "abort_incomplete_multipart_upload", {}))) == 0 ? [] : [lookup(rule.value, "abort_incomplete_multipart_upload", {})]

        content {
          days_after_initiation = lookup(abort_incomplete_multipart_upload.value, "days_after_initiation", null)
        }
      }

      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = length(keys(lookup(rule.value, "expiration", {}))) == 0 ? [] : [lookup(rule.value, "expiration", {})]

        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = lookup(rule.value, "transition", [])

        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }

      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = length(keys(lookup(rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [lookup(rule.value, "noncurrent_version_expiration", {})]

        content {
          newer_noncurrent_versions = lookup(noncurrent_version_expiration.value, "versions", null)
          noncurrent_days           = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }

      # Several blocks - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = lookup(rule.value, "noncurrent_version_transition", [])

        content {
          newer_noncurrent_versions = lookup(noncurrent_version_transition.value, "versions", null)
          noncurrent_days           = lookup(noncurrent_version_transition.value, "days", null)
          storage_class             = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "accces_logs_lifecycle" {
  for_each = {
    # id is the key, value is the lyfecycle object
    for lc in var.access_log_bucket_lifecycle_rules : lc.id => lc
  }

  bucket = aws_s3_bucket.access_log_bucket[0].id

  rule {
    id     = each.value.id
    status = each.value.enabled ? "Enabled" : "Disabled"

    filter {
      prefix = each.value.prefix
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = lookup(each.value, "abort_incomplete_multipart_upload_days", null)
    }

    # Max 1 block - expiration
    dynamic "expiration" {
      for_each = length(keys(lookup(each.value, "expiration", {}))) == 0 ? [] : [lookup(each.value, "expiration", {})]

      content {
        date                         = lookup(expiration.value, "date", null)
        days                         = lookup(expiration.value, "days", null)
        expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
      }
    }

    # Several blocks - transition
    dynamic "transition" {
      for_each = lookup(each.value, "transition", [])

      content {
        date          = lookup(transition.value, "date", null)
        days          = lookup(transition.value, "days", null)
        storage_class = transition.value.storage_class
      }
    }
  }
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}
