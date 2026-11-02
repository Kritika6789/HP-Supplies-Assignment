/*
 * (C) Copyright 2019-2021 HP Development Company, L.P.
 * Confidential computer software. Valid license from HP required for possession, use or copying.
 * Consistent with FAR 12.211 and 12.212, Commercial Computer Software,
 * Computer Software Documentation, and Technical Data for Commercial Items are licensed
 * to the U.S. Government under vendor's standard commercial license.
 */

locals {
  default_alarms = {
    "ReadCapacityUnitsLimitAlarm" = {
      "alarm_name"          = format("%s - DynamoDB Read Capacity Units Limit", aws_dynamodb_table.table.name)
      "alarm_description"   = "Alarm when read capacity reaches 80% of my provisioned read capacity"
      "comparison_operator" = "GreaterThanOrEqualToThreshold"
      "evaluation_periods"  = 1
      "metric_name"         = "ConsumedReadCapacityUnits"
      "namespace"           = "AWS/DynamoDB"
      "period"              = 60
      "statistic"           = "Sum"
      "threshold"           = var.read_capacity * 60 * 0.8

      "dimensions" = {
        TableName = aws_dynamodb_table.table.name
      }

      "ok_actions"                = [var.alarm_sns_topic_arn]
      "insufficient_data_actions" = [var.alarm_sns_topic_arn]
      "alarm_actions"             = [var.alarm_sns_topic_arn]
    },

    "WriteCapacityUnitsLimitAlarm" = {
      "alarm_name"          = format("%s - DynamoDB Write Capacity Units Limit", aws_dynamodb_table.table.name)
      "alarm_description"   = "Alarm when write capacity reaches 80% of my provisioned write capacity"
      "comparison_operator" = "GreaterThanOrEqualToThreshold"
      "evaluation_periods"  = 1
      "metric_name"         = "ConsumedWriteCapacityUnits"
      "namespace"           = "AWS/DynamoDB"
      "period"              = 60
      "threshold"           = var.write_capacity * 60 * 0.8
      "statistic"           = "Sum"

      "dimensions" = {
        TableName = aws_dynamodb_table.table.name
      }

      "ok_actions"                = [var.alarm_sns_topic_arn]
      "insufficient_data_actions" = [var.alarm_sns_topic_arn]
      "alarm_actions"             = [var.alarm_sns_topic_arn]
    },

    "SystemErrorsAlarm" = {
      "alarm_name"          = format("%s - DynamoDB System Error", aws_dynamodb_table.table.name)
      "alarm_description"   = "Alarm when system errors occur"
      "comparison_operator" = "GreaterThanThreshold"
      "evaluation_periods"  = 1
      "metric_name"         = "SystemErrors"
      "namespace"           = "AWS/DynamoDB"
      "period"              = 60
      "threshold"           = 0
      "statistic"           = "Sum"

      "dimensions" = {
        TableName = aws_dynamodb_table.table.name
        Operation = "aDynamoDBOperation"
      }

      "ok_actions"                = [var.alarm_sns_topic_arn]
      "insufficient_data_actions" = [var.alarm_sns_topic_arn]
      "alarm_actions"             = [var.alarm_sns_topic_arn]
    },

    "RequestsExceedingThroughputAlarm" = {
      "alarm_name"          = format("%s - DynamoDB Requests Exceeding Throughput", aws_dynamodb_table.table.name)
      "alarm_description"   = "Alarm when my requests are exceeding provisioned throughput quotas of my table"
      "comparison_operator" = "GreaterThanThreshold"
      "evaluation_periods"  = 1
      "metric_name"         = "ThrottledRequests"
      "namespace"           = "AWS/DynamoDB"
      "period"              = 300
      "threshold"           = 0
      "statistic"           = "Sum"

      "dimensions" = {
        TableName = aws_dynamodb_table.table.name
        Operation = "aDynamoDBOperation"
      }

      "ok_actions"                = [var.alarm_sns_topic_arn]
      "insufficient_data_actions" = [var.alarm_sns_topic_arn]
      "alarm_actions"             = [var.alarm_sns_topic_arn]
    },
  }
}

# Commented out for local / LocalStack testing to avoid private git clone over SSH
# module "elasticsearch-cloudwatch-alarms" {
#   count  = var.enable_alarms ? 1 : 0
#   source = "git::ssh://git@github.azc.ext.hp.com/runway/terraform-aws-cloudwatch.git//modules/cloudwatch-alarms?ref=v3.0.3"
#
#   default_alarms          = local.default_alarms
#   additional_alarms       = var.additional_alarms
#   override_default_alarms = var.override_default_alarms
#   sns_topic               = var.alarm_sns_topic_arn
# }
