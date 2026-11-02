/*
 * (C) Copyright 2019-2021 HP Development Company, L.P.
 * Confidential computer software. Valid license from HP required for possession, use or copying.
 * Consistent with FAR 12.211 and 12.212, Commercial Computer Software,
 * Computer Software Documentation, and Technical Data for Commercial Items are licensed
 * to the U.S. Government under vendor's standard commercial license.
 */

locals {
  hash = [{
    name = var.hash_key
    type = var.hash_key_type
  }]

  range = [{
    name = var.range_key
    type = var.range_key_type
  }]

  # This workaround is to prevent the module from breaking for users using the existing var.region_replicas
  # The workaround can be removed in the next major version, as well as the variable var.replica_regions and the exaple and test case create-global-thread-table-deprecated
  replicas = length(var.replica_regions) > 0 ? [for x in var.replica_regions : { region_name = x, propagate_tags = false, point_in_time_recovery = false, kms_key_arn = "" }] : var.replica_configurations

  // Since range_key is optional...
  default_attributes = var.range_key == null ? local.hash : concat(local.hash, local.range)
  attributes         = concat(local.default_attributes, var.additional_attributes)

  //Global table settings...
  stream_enabled   = var.enable_stream == true ? true : length(local.replicas) > 0 ? true : false
  stream_view_type = var.enable_stream == true ? var.stream_view_type : length(local.replicas) > 0 ? "NEW_AND_OLD_IMAGES" : null

  //Resource policy settings...
  resource_policy = can(jsondecode(var.resource_policy)) ? var.resource_policy : jsonencode(var.resource_policy)
}

resource "aws_dynamodb_table" "table" {
  name                        = var.table_name
  hash_key                    = var.hash_key
  range_key                   = var.range_key
  billing_mode                = var.billing_mode
  read_capacity               = var.billing_mode == "PAY_PER_REQUEST" ? null : var.read_capacity
  write_capacity              = var.billing_mode == "PAY_PER_REQUEST" ? null : var.write_capacity
  stream_enabled              = local.stream_enabled
  stream_view_type            = local.stream_view_type
  deletion_protection_enabled = var.deletion_protection_enabled
  tags                        = merge(var.tags, { Name = var.table_name })

  dynamic "ttl" {
    for_each = var.enable_ttl == true ? [1] : []
    content {
      enabled        = var.enable_ttl
      attribute_name = var.ttl_attribute_name
    }
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  dynamic "server_side_encryption" {
    for_each = var.kms_key_arn == "" ? [] : [1]
    content {
      enabled     = true
      kms_key_arn = var.kms_key_arn
    }
  }

  dynamic "attribute" {
    for_each = local.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "replica" {
    for_each = local.replicas
    content {
      region_name            = replica.value.region_name
      kms_key_arn            = replica.value.kms_key_arn
      point_in_time_recovery = replica.value.point_in_time_recovery
      propagate_tags         = replica.value.propagate_tags
    }
  }

  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes
    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = lookup(local_secondary_index.value, "non_key_attributes", null)
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", null)
      range_key          = lookup(global_secondary_index.value, "range_key", null)
      read_capacity      = lookup(global_secondary_index.value, "read_capacity", null)
      write_capacity     = lookup(global_secondary_index.value, "write_capacity", null)
    }
  }
}

resource "aws_dynamodb_resource_policy" "table_policy" {
  count = var.resource_policy == "" ? 0 : 1

  resource_arn = aws_dynamodb_table.table.arn
  policy       = local.resource_policy
}
