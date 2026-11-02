variable "region" {
  default = "us-west-2"
}

variable "bucket" {
  description = "The name of the s3 bucket"
  default     = ""
}

variable "account_id" {
  default = ""
}

variable "configure_policy" {
  type    = bool
  default = false
}

variable "lifecycle_rule_id" {
  default = ""
}

variable "lifecycle_config_enabled" {
  default = false
}

variable "lifecycle_rule_prefix" {
  default = ""
}

variable "lifecycle_expiration_days" {
  default = 1
}

variable "configure_server_side_encryption" {
  default = false
}

variable "lifecycle_transition_days" {
  default = 30
}

variable "lifecycle_transition_storage_class" {
  default = "STANDARD_IA"
}

variable "enable_logging" {
  default = false
}

#SQS
variable "sqsname" {
  description = "The SQS Queue name"
  default     = "test-sqs-queue"
}

variable "sqs_all_identifiers" {
  type        = list(string)
  description = "List of AWS user or role ARNs that have full control over this sqs queue."
  default     = ["*"]
}

variable "configure_dead_letter_queue" {
  type        = bool
  description = "Flag indicating if a dead letter queue should be configured"
  default     = false
}
variable "s3_event" {
  type        = list(string)
  description = "The event when Notification needs to be sent"
  default     = ["s3:ObjectCreated:*"]
}

variable "filter_suffix" {
  type        = string
  description = "The name of the s3 bucket"
  default     = ".log"
}
