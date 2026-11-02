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

#SNS
variable "snsname" {
  description = "The SNS topic name"
  default     = "test-sns-topic"
}

variable "sns_all_identifiers" {
  type        = list(string)
  description = "List of AWS user or role ARNs that have full control over this sns topic."
  default     = ["*"]
}

variable "s3_event" {
  type        = list(string)
  description = "The event when Notification needs to be sent"
  default     = ["s3:ObjectCreated:*"]
}

variable "filter_suffix" {
  type        = string
  description = "Filter notifications on the suffix"
  default     = ".log"
}
