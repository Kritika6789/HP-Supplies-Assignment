/*
 * (C) Copyright 2019-2021 HP Development Company, L.P.
 * Confidential computer software. Valid license from HP required for possession, use or copying.
 * Consistent with FAR 12.211 and 12.212, Commercial Computer Software,
 * Computer Software Documentation, and Technical Data for Commercial Items are licensed
 * to the U.S. Government under vendor's standard commercial license.
 */

provider "aws" {
  region = var.region
}

module "dynamodb" {
  source = "../../modules/dynamodb-table"

  table_name             = var.table_name
  replica_configurations = var.replica_configurations
  hash_key               = "ForumName"
  hash_key_type          = "S"
  range_key              = "Subject"
  range_key_type         = "S"

  # Due to https://github.com/hashicorp/terraform-provider-aws/issues/13097
  billing_mode         = "PAY_PER_REQUEST"
  auto_scaling_enabled = false
}
