locals {
  role_name_prefix      = var.role_name_prefix
  role_name_untruncated = "${local.role_name_prefix}_${var.source_bucket_name}"
  role_name             = length(local.role_name_untruncated) > 63 ? substr(local.role_name_untruncated, 0, 63) : local.role_name_untruncated
  source_bucket_arn     = "arn:aws:s3:::${var.source_bucket_name}"
  destination_bucket_arns = [
    for config in var.destination_replication_configurations :
    "arn:aws:s3:::${lookup(config, "destination_bucket_name", "")}"
  ]
}

resource "aws_iam_role" "s3_crr_role" {
  name                 = local.role_name
  path                 = var.role_path
  permissions_boundary = var.role_permissions_boundary
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "s3.amazonaws.com"
        },
        "Action" : "sts:AssumeRole",
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_crr_role_policy" {
  name   = "${local.role_name}_policy"
  role   = aws_iam_role.s3_crr_role.id
  policy = data.aws_iam_policy_document.s3_crr_role_policy_document.json
}

resource "aws_s3_bucket_replication_configuration" "s3_replication_configuration" {
  bucket = var.source_bucket_name
  role   = aws_iam_role.s3_crr_role.arn

  dynamic "rule" {
    for_each = var.destination_replication_configurations

    content {
      id       = "rule_${local.source_bucket_arn}_${rule.key}"
      status   = lookup(rule.value, "status", "Disabled")
      priority = index(keys(var.destination_replication_configurations), rule.key) + 1

      destination {
        bucket  = "arn:aws:s3:::${lookup(rule.value, "destination_bucket_name", "")}"
        account = lookup(rule.value, "destination_account_id", data.aws_caller_identity.current.account_id)

        dynamic "access_control_translation" {
          for_each = lookup(rule.value, "destination_account_id", "") == data.aws_caller_identity.current.account_id ? [] : [1]
          content {
            owner = lookup(rule.value, "access_control_translation", "Destination")
          }
        }
      }

      delete_marker_replication {
        status = lookup(rule.value, "delete_marker_replication", "Disabled")
      }

      dynamic "filter" {
        for_each = [lookup(rule.value, "filter", {})] # Accessing filter from each.value
        content {
          prefix = lookup(filter.value, "prefix", null)
          dynamic "tag" {
            for_each = lookup(filter.value, "tag", null) != null ? [lookup(filter.value, "tag")] : []
            content {
              key   = lookup(tag.value, "key", null)
              value = lookup(tag.value, "value", null)
            }
          }
          dynamic "and" {
            for_each = lookup(filter.value, "and", null) != null ? [lookup(filter.value, "and")] : []
            content {
              prefix = lookup(and.value, "prefix", null)
              tags   = lookup(and.value, "tags", null)
            }
          }
        }
      }
    }
  }
}
