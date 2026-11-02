data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "empty" {}

## define the policy recommended by Cyber Security to block requests from TLS 1.0 and 1.1
data "aws_iam_policy_document" "s3_tls_enforcement" {
  source_policy_documents = [data.aws_iam_policy_document.empty.json]
  override_policy_documents = var.enforce_tls ? [jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AddTLS1.0Restriction",
        "Effect" : "Deny",
        "Principal" : "*",
        "Action" : "*",
        "Resource" : "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.bucket.id}/*",
        "Condition" : {
          "NumericEquals" : {
            "s3:TlsVersion" : "1.0"
          }
        }
      },
      {
        "Sid" : "AddTLS1.1Restriction",
        "Effect" : "Deny",
        "Principal" : "*",
        "Action" : "*",
        "Resource" : "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.bucket.id}/*",
        "Condition" : {
          "NumericEquals" : {
            "s3:TlsVersion" : "1.1"
          }
        }
      },
      {
        "Sid" : "DenyHTTPAccess",
        "Effect" : "Deny",
        "Principal" : "*",
        "Action" : "*",
        "Resource" : [
          "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.bucket.id}/*",
        ],
        "Condition" : {
          "Bool" : {
            "aws:SecureTransport" : "false"
          }
        }
      }
    ]
  })] : [data.aws_iam_policy_document.empty.json]
}

data "aws_iam_policy_document" "policy" {
  source_policy_documents = var.enforce_tls ? [data.aws_iam_policy_document.s3_tls_enforcement.json] : [data.aws_iam_policy_document.empty.json]

  override_policy_documents = var.policy == null ? [data.aws_iam_policy_document.empty.json] : [var.policy]
}

data "aws_iam_policy_document" "inventory_destination_bucket_policy" {
  for_each = local.inventory_configurations_normalized

  statement {
    effect  = "Allow"
    actions = ["s3:PutObject"]

    principals {
      type        = "Service"
      identifiers = ["s3.${data.aws_partition.current.dns_suffix}"]
    }

    resources = [
      each.value.prefix == ""
      ? "${each.value.bucket_arn}/*"
      : "${each.value.bucket_arn}/${each.value.prefix}/*"
    ]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.bucket.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}
