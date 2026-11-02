variable "bucket_name" {
  type        = string
  description = "The name of the s3 bucket"
}

variable "lambda_arn" {
  type        = string
  description = "The arn of the Lambda function"
}

variable "s3_event" {
  type        = list(any)
  description = "The event when Notification needs to be sent"
  default     = ["s3:ObjectCreated:*"]
}

variable "filter_suffix" {
  type        = string
  description = "Filter notifications on the suffix"
  default     = ".log"
}

variable "filter_prefix" {
  type        = string
  description = "Filter notifications on the prefix"
  default     = "AWSLogs/"
}
