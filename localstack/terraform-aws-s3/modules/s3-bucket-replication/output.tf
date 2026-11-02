output "replication_role_arn" {
  description = "The ARN of the IAM role used for S3 replication"
  value       = aws_iam_role.s3_crr_role.arn
}

output "replication_role_name" {
  description = "The name of the IAM role used for S3 replication"
  value       = aws_iam_role.s3_crr_role.name
}
