variable "bucket_name" {
  description = "Name of the S3 source bucket."
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the S3 source bucket."
  type        = string
}

variable "table_name" {
  description = "Name of the DynamoDB destination table."
  type        = string
}

variable "table_arn" {
  description = "ARN of the DynamoDB destination table."
  type        = string
}

variable "aws_region" {
  description = "AWS or LocalStack region."
  type        = string
}

variable "localstack" {
  description = "Whether the Lambda function connects to LocalStack."
  type        = bool
}

variable "lambda_localstack_endpoint" {
  description = "LocalStack endpoint reachable from the Lambda container."
  type        = string
}

variable "localstack_endpoint" {
  description = "LocalStack endpoint URL."
  type        = string
  default     = "http://localhost:4566"
}

variable "csv_prefix" {
  description = "Only process CSV objects under this optional S3 prefix."
  type        = string
}
