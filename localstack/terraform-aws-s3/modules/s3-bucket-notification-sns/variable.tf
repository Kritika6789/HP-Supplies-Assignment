variable "bucket_name" {
  type        = string
  description = "The name of the s3 bucket"
}

variable "topic_arn" {
  type        = string
  description = "The arn of the SNS topic"
}

variable "s3_event" {
  type        = list(any)
  description = "The event when Notification needs to be sent"
  default     = ["s3:ObjectCreated:*"]
}

variable "filter_prefix" {
  type        = string
  description = "Object key name prefix."
  default     = null
}

variable "filter_suffix" {
  type        = string
  description = "Object key name suffix."
  default     = ".log"
}
