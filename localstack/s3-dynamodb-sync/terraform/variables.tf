variable "aws_region" {
  description = "AWS or LocalStack region."
  type        = string
  default     = "us-east-1"
}

variable "localstack" {
  description = "Use LocalStack service endpoints and test credentials."
  type        = bool
  default     = false
}

variable "localstack_endpoint" {
  description = "LocalStack edge endpoint reachable from the Terraform host."
  type        = string
  default     = "http://localhost:4566"
}

variable "lambda_localstack_endpoint" {
  description = "LocalStack edge endpoint reachable from the Lambda container."
  type        = string
  default     = "http://host.docker.internal:4566"
}

variable "bucket_name" {
  description = "Globally unique AWS bucket name, or a local bucket name for LocalStack."
  type        = string
}

variable "force_destroy" {
  description = "Allow Terraform to delete a non-empty bucket. Keep false for persistent environments."
  type        = bool
  default     = false
}

variable "table_name" {
  description = "Name of the DynamoDB table."
  type        = string
  default     = "csv-records"
}

variable "csv_prefix" {
  description = "Only process CSV objects under this optional S3 prefix."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to supported AWS resources."
  type        = map(string)
  default     = {}
}
