/*
 * (C) Copyright 2019-2021 HP Development Company, L.P.
 * Confidential computer software. Valid license from HP required for possession, use or copying.
 * Consistent with FAR 12.211 and 12.212, Commercial Computer Software,
 * Computer Software Documentation, and Technical Data for Commercial Items are licensed
 * to the U.S. Government under vendor's standard commercial license.
 */

variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "billing_mode" {
  description = "Billing mode for the DynamoDB table. Either PROVISIONED or PAY_PER_REQUEST"
  default     = "PROVISIONED"
  type        = string
}

variable "deletion_protection_enabled" {
  description = "Enable deletion protection"
  default     = false
  type        = bool
}

variable "hash_key" {
  description = "The attribute to use as the partition key of the DynamoDB table"
  type        = string
}

variable "hash_key_type" {
  description = "The key type. Either 'S', 'N' or 'B' for (S)tring, (N)umber or (B)inary data"
  default     = "S"
  type        = string
}

variable "range_key" {
  description = "The attribute to use as the sort key of the DynamoDB table"
  default     = null
  type        = string
}

variable "range_key_type" {
  description = "The key type. Either 'S', 'N' or 'B' for (S)tring, (N)umber or (B)inary data"
  default     = "S"
  type        = string
}

variable "replica_regions" {
  description = "[deprecated] Regions for creating replicas of the DynamoDB table"
  default     = []
  type        = list(string)
}

variable "replica_configurations" {
  description = <<-EOF
  Configuration for replicas of the DynamoDB table
  * region_name - Region name of the replica.
  * propagate_tags - Whether to propagate the global table's tags to a replica. Default is false. Changes to tags only move in one direction: from global (source) to replica. In other words, tag drift on a replica will not trigger an update. Tag or replica changes on the global table, whether from drift or configuration changes, are propagated to replicas. Changing from true to false on a subsequent apply means replica tags are left as they were, unmanaged, not deleted.
  * point_in_time_recovery - Whether to enable Point In Time Recovery for the replica.
  * kms_key_arn - ARN of the CMK that should be used for the AWS KMS encryption. This argument should only be used if the key is different from the default KMS-managed DynamoDB key
    If a CMK is used in the primary table, each replica must also have an in region cmk specified.

  EOF
  default     = []
  type = list(object({
    region_name            = string
    propagate_tags         = bool
    point_in_time_recovery = bool
    kms_key_arn            = string
  }))
}

variable "point_in_time_recovery_enabled" {
  description = "Whether to enable point-in-time recovery. It can take 10 minutes to enable for new tables."
  default     = false
  type        = bool
}

variable "write_capacity" {
  description = "The number of write units for this DynamoDB table"
  default     = 5
  type        = number
}

variable "read_capacity" {
  description = "The number of read units for this DynamoDB table"
  default     = 5
  type        = number
}

variable "additional_attributes" {
  description = "Additional attributes for this DynamoDB table"
  default     = []

  type = list(object({
    name = string
    type = string
  }))
}

variable "local_secondary_indexes" {
  description = "Describe LSIs for this DynamoDB table. Cannot change this definition after creation"
  default     = []

  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = list(string)
  }))
}

variable "global_secondary_indexes" {
  description = "Describe GSIs for this DynamoDB table"
  default     = []

  type = list(object({
    name               = string
    hash_key           = string
    range_key          = string
    projection_type    = string
    read_capacity      = number
    write_capacity     = number
    non_key_attributes = list(string)
  }))
}

variable "enable_ttl" {
  description = "Indicates whether ttl is enabled (true) or disabled (false)"
  default     = false
  type        = bool
}

variable "ttl_attribute_name" {
  description = "The name of the table attribute to store the TTL timestamp in"
  default     = "ttl"
  type        = string
}

variable "tags" {
  description = "A map of tags to add into all resources"
  default     = {}
  type        = map(string)
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used to encrypt the table. If not set, the Default key is used."
  type        = string
  default     = ""
}

variable "resource_policy" {
  description = "A list of policies to attach to the DynamoDB table."
  default     = ""
  type        = string

  validation {
    condition     = length(replace(var.resource_policy, "/\\s+/", "")) <= 20480
    error_message = "The resource_policy cannot be longer than 20480 characters."
  }
}

# Autoscaling Settings
# - - - - - - - - - - - - - - - - - - - - - - -

variable "auto_scaling_enabled" {
  description = "DynamoDB table autoscaling"
  default     = true
  type        = bool
}

variable "enable_stream" {
  description = "Enable DynamoDB Stream"
  default     = false
  type        = bool
}

variable "enable_alarms" {
  description = "Create the module's default and additional CloudWatch alarms."
  default     = true
  type        = bool
}

variable "stream_view_type" {
  description = "The type of data from the stream to be published. Valid values are KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES"
  default     = "KEYS_ONLY"
  type        = string
}

variable "auto_scaling_read_min_capacity" {
  description = "The autoscaling minimun read capacity"
  default     = 5
  type        = number
}

variable "auto_scaling_read_max_capacity" {
  description = "The autoscaling maximum read capacity"
  default     = 40000
  type        = number
}

variable "auto_scaling_write_min_capacity" {
  description = "The autoscaling minimun write capacity"
  default     = 5
  type        = number
}

variable "auto_scaling_write_max_capacity" {
  description = "The autoscaling maximum write capacity"
  default     = 40000
  type        = number
}

variable "auto_scaling_read_policy_target" {
  description = "The autoscaling read target (%) value"
  default     = 70
  type        = number
}

variable "auto_scaling_write_policy_target" {
  description = "The autoscaling write target (%) value"
  default     = 70
  type        = number
}

# Alarms Settings
# - - - - - - - - - - - - - - - - - - - - - - -

variable "alarm_sns_topic_arn" {
  description = "SNS topic ARN for the Cloudwatch Alarms created in this module"
  default     = ""
  type        = string
}

variable "override_default_alarms" {
  description = "Object to override default alarms"
  default     = {}
}

variable "additional_alarms" {
  description = "Object to create additional alarms"
  default     = {}
}
