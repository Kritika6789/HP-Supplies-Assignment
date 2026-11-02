locals {
  # BucketOwnerEnforced disables ACL, so when this is enabled, the var.acl parameter should be ignored
  private_access = var.object_ownership == "BucketOwnerEnforced" ? (var.private_access) : (var.acl == "private")

  inventory_configurations_normalized = {
    for name, config in var.inventory_configurations : name => {
      enabled                  = coalesce(try(config.enabled, null), true)
      included_object_versions = coalesce(try(config.included_object_versions, null), "Current")
      optional_fields          = try(config.optional_fields, null)
      schedule_frequency       = coalesce(try(config.schedule_frequency, null), "Daily")
      filter_prefix            = try(config.filter_prefix, null)
      bucket_arn               = can(config.destination.bucket_arn) && config.destination.bucket_arn != null ? config.destination.bucket_arn : ""
      bucket_name              = replace(can(config.destination.bucket_arn) && config.destination.bucket_arn != null ? config.destination.bucket_arn : "", "arn:${data.aws_partition.current.partition}:s3:::", "")
      format                   = coalesce(try(config.destination.format, null), "CSV")
      account_id               = coalesce(try(config.destination.account_id, null), data.aws_caller_identity.current.account_id)
      prefix                   = trim(can(config.destination.prefix) && config.destination.prefix != null ? config.destination.prefix : "", "/")
      encryption               = try(config.destination.encryption, null)
      sse_kms_key_id           = try(config.destination.encryption.sse_kms_key_id, null)
      sse_s3                   = coalesce(try(config.destination.encryption.sse_s3, null), false)
    }
  }
}

