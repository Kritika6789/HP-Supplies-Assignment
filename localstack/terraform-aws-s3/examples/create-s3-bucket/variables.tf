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

variable "lifecycle_abort_incomplete_multipart_upload_days" {
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

variable "inventory_destination_bucket_arn" {
  description = "Destination bucket ARN for S3 inventory reports"
  default     = ""
}

variable "configure_inventory" {
  description = "Enable S3 inventory configuration"
  type        = bool
  default     = false
}
