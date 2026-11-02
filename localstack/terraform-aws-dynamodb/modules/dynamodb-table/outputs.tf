/*
 * (C) Copyright 2019-2021 HP Development Company, L.P.
 * Confidential computer software. Valid license from HP required for possession, use or copying.
 * Consistent with FAR 12.211 and 12.212, Commercial Computer Software,
 * Computer Software Documentation, and Technical Data for Commercial Items are licensed
 * to the U.S. Government under vendor's standard commercial license.
 */

output "table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.table.arn
}

output "table_id" {
  description = "DynamoDB table ID"
  value       = aws_dynamodb_table.table.id
}

output "stream_arn" {
  description = "DynamoDB stream ARN"
  value       = aws_dynamodb_table.table.stream_arn
}
