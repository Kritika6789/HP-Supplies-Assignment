/*
 * (C) Copyright 2019-2021 HP Development Company, L.P.
 * Confidential computer software. Valid license from HP required for possession, use or copying.
 * Consistent with FAR 12.211 and 12.212, Commercial Computer Software,
 * Computer Software Documentation, and Technical Data for Commercial Items are licensed
 * to the U.S. Government under vendor's standard commercial license.
 */

provider "aws" {
  region = var.region
}
# KMS Key creation

data "aws_caller_identity" "current" {
}

data "aws_iam_policy_document" "policy-doc" {
  statement {
    actions = ["kms:*"]
    effect  = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    resources = ["*"]
  }

  statement {
    sid = "Enable IAM User Permissions"

    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt",
    ]

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.kms_identifiers
    }

    principals {
      type        = "Service"
      identifiers = ["dynamodb.amazonaws.com"]
    }

    resources = ["*"]
  }
}

resource "aws_kms_key" "a" {
  description = "${var.table_name} kms key for Server Side Encryption"
  policy      = data.aws_iam_policy_document.policy-doc.json
}

resource "aws_kms_alias" "a" {
  name          = "alias/${var.table_name}-sse-kms-key"
  target_key_id = aws_kms_key.a.key_id
}

module "dynamodb" {
  source = "../../modules/dynamodb-table"

  table_name     = var.table_name
  hash_key       = "Id"
  hash_key_type  = "S"
  range_key      = "ReplyDateTime"
  range_key_type = "S"

  kms_key_arn = aws_kms_key.a.arn

  additional_attributes = [
    {
      name = "PostedBy"
      type = "S"
    },
    {
      name = "Message"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name               = "PostedBy-Message-index"
      hash_key           = "PostedBy"
      range_key          = "Message"
      write_capacity     = 5
      read_capacity      = 5
      projection_type    = "ALL"
      non_key_attributes = null
    }
  ]
}
