variable "source_bucket_name" {
  description = "The name of the source bucket for replication"
  type        = string
}

variable "destination_replication_configurations" {
  description = <<-EOF
  A map of replication configurations for the destination buckets. Each configuration is a map with the following fields:
  - destination_bucket_name: The name of the destination bucket for replication (Required).
  - destination_account_id: The AWS account ID of the destination bucket for cross-account replication (Optional). If not provided, defaults to the current account.
  - status: The status of the replication rule. Possible values are "Enabled" or "Disabled" (Required).
  - delete_marker_replication: Specifies whether to replicate delete markers. Possible values are "Enabled" or "Disabled" (Optional).
  - filter: An object defining the filter for the replication rule (Optional). Can include exactly one of:
    - prefix: Object key name prefix that identifies the subset of objects to which the rule applies (Optional).
    - tag: Configuration block for specifying a tag key and value (Optional).
    - and: Configuration block for specifying rule filters with both prefix and tags (Optional).

  Example Usage (without filtering):
  destination_replication_configurations = {
    config1 = {
      destination_bucket_name    = "bucket2"
      status                     = "Enabled"
      delete_marker_replication  = "Enabled"
      filter                     = {}
    }
  }

  Example Usage (cross-account replication):
  destination_replication_configurations = {
    cross_account = {
      destination_bucket_name    = "bucket2"
      destination_account_id     = "123456789012"
      status                     = "Enabled"
      delete_marker_replication  = "Enabled"
      filter                     = {}
    }
  }

  Example Usage (using prefix):
  destination_replication_configurations = {
    config1 = {
      destination_bucket_name    = "bucket2"
      status                     = "Enabled"
      delete_marker_replication  = "Enabled"
      filter = {
        prefix = "logs/"
      }
    }
  }

  Example Usage (using tag):
  destination_replication_configurations = {
    config2 = {
      destination_bucket_name    = "bucket3"
      status                     = "Disabled"
      delete_marker_replication  = "Enabled"
      filter = {
        tag = {
          key   = "Environment"
          value = "Prod"
        }
      }
    }
  }

  Example Usage (using and):
  destination_replication_configurations = {
    config3 = {
      destination_bucket_name    = "bucket4"
      status                     = "Enabled"
      delete_marker_replication  = "Disabled"
      filter = {
        and = {
          prefix = "data/"
          tags   = {
            Project = "Project1"
            Owner   = "Owner1"
          }
        }
      }
    }
  }
  EOF
  type        = map(any) # Allowing any type for the map values
}

# IAM role parameters
variable "role_path" {
  type        = string
  default     = "/"
  description = "IAM role path."
}

variable "role_name_prefix" {
  type        = string
  default     = "s3-replication"
  description = "Creates a role name beginning with the specified prefix."
}

variable "role_permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the user."
  default     = null
  type        = string
}

