/*
 * (C) Copyright 2019-2021 HP Development Company, L.P.
 * Confidential computer software. Valid license from HP required for possession, use or copying.
 * Consistent with FAR 12.211 and 12.212, Commercial Computer Software,
 * Computer Software Documentation, and Technical Data for Commercial Items are licensed
 * to the U.S. Government under vendor's standard commercial license.
 */

data "aws_caller_identity" "current" {}

# Using the Least Privilege principle, 
# define the permissions required to provision the modules defined in this repository
data "aws_iam_policy_document" "policy" {
  statement {
    sid = "DynamoDB"
    actions = [
      "dynamodb:*",
      "application-autoscaling:*",
      "iam:CreateServiceLinkedRole",
    ]
    resources = ["*"]
  }

  statement {
    sid = "DynamoDBAlarms"
    actions = [
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:EnableAlarmActions",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DisableAlarmActions",
      "cloudwatch:ListTagsForResource",
      "cloudwatch:DescribeAlarms"
    ]
    resources = [
      format("arn:aws:cloudwatch:*:%s:alarm:*", local.account_id)
    ]
  }

  statement {
    sid = "DynamoDBCW"
    actions = [
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:ListDashboards",
      "cloudwatch:ListMetrics"
    ]
    resources = ["*"]
  }
}

# If additional permissions are required for the integration tests,
# they should be defined here
data "aws_iam_policy_document" "test" {
  source_policy_documents = [data.aws_iam_policy_document.policy.json]

  statement {
    sid = "RUNWAYPROVISIONINGTEST"
    actions = [
      "kms:*",
    ]
    resources = [
      "*",
    ]
  }
}
