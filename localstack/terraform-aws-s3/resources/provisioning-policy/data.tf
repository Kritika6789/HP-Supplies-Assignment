/*
 * (C) Copyright 2019-2020 HP Development Company, L.P.
 * Confidential computer software. Valid license from HP required for possession, use or copying.
 * Consistent with FAR 12.211 and 12.212, Commercial Computer Software,
 * Computer Software Documentation, and Technical Data for Commercial Items are licensed
 * to the U.S. Government under vendor's standard commercial license.
 */

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "policy" {

  statement {
    sid    = "S3Global"
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:CreateAccessPoint",
      "s3:CreateAccessPointForObjectLambda",
      "s3:CreateMultiRegionAccessPoint",
      "s3:DeleteAccessPoint*",
      "s3:DeleteBucket*",
      "s3:DeleteMultiRegionAccessPoint",
      "s3:DeleteObject",
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersionTagging",
      "s3:DescribeMultiRegionAccessPointOperation",
      "s3:GetAccelerateConfiguration",
      "s3:Get*",
      "s3:List*",
      "s3:ObjectOwnerOverrideToBucketOwner",
      "s3:PutAccelerateConfiguration",
      "s3:PutAccessPoint*",
      "s3:PutAccountPublicAccessBlock",
      "s3:PutBucket*",
      "s3:PutEncryptionConfiguration",
      "s3:PutIntelligentTieringConfiguration",
      "s3:PutInventoryConfiguration",
      "s3:PutLifecycleConfiguration",
      "s3:PutMetricsConfiguration",
      "s3:PutMultiRegionAccessPointPolicy",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectLegalHold",
      "s3:PutObjectRetention",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionAcl",
      "s3:PutObjectVersionTagging",
      "s3:PutReplicationConfiguration",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${var.name_prefix}*",
    ]
  }

  statement {
    sid = "IAM"
    actions = [
      "iam:Get*",
      "iam:List*",
      "iam:CreateRole",
      "iam:PassRole",
      "iam:DeleteRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:Tag*",
      "iam:Untag*",
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:role/*",
      "arn:aws:iam::${local.account_id}:policy/*",
    ]
  }
}

data "aws_iam_policy_document" "test" {
  source_policy_documents = [data.aws_iam_policy_document.policy.json]

  statement {
    sid    = "KMSDecryption"
    effect = "Allow"
    actions = [
      "kms:CreateKey",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListResourceTags",
      "kms:ScheduleKeyDeletion",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "SqsPermission"
    effect = "Allow"
    actions = [
      "sqs:*",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "SnsPermission"
    effect = "Allow"
    actions = [
      "sns:*",
    ]
    resources = [
      "*"
    ]
  }
}
