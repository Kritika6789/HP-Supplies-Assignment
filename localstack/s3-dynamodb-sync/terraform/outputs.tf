output "bucket_name" {
  description = "S3 bucket receiving CSV files."
  value       = module.bucket.bucket
}

output "table_name" {
  description = "DynamoDB table populated by the S3 event processor."
  value       = var.table_name
}

output "lambda_function_name" {
  description = "Lambda function processing CSV object events."
  value       = module.csv_sync.function_name
}
