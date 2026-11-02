locals {
  formatted_destination_bucket_arns = formatlist("%s/*", local.destination_bucket_arns)
  statement_1_resources = concat([
    local.source_bucket_arn, "${local.source_bucket_arn}/*"
  ], local.destination_bucket_arns, local.formatted_destination_bucket_arns)
  statement_2_resources = concat(["${local.source_bucket_arn}/*"], local.formatted_destination_bucket_arns)
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "s3_crr_role_policy_document" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetReplicationConfiguration",
      "s3:GetObject*"
    ]
    effect    = "Allow"
    resources = local.statement_1_resources
  }

  statement {
    actions = [
      "s3:Replicate*",
      "s3:PutBucketVersioning",
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]
    effect    = "Allow"
    resources = local.statement_2_resources
  }
}
