include "backend" {
  path = find_in_parent_folders("common_backend.hcl")
}

terraform {
  source = "../../../../terraform-aws-dynamodb/modules/dynamodb-table"
}

inputs = {
  table_name                     = get_env("SYNC_TABLE_NAME", "csv-records")
  hash_key                       = "source_key"
  hash_key_type                  = "S"
  range_key                      = "row_number"
  range_key_type                 = "N"
  billing_mode                   = "PAY_PER_REQUEST"
  auto_scaling_enabled           = false
  enable_alarms                  = false
  point_in_time_recovery_enabled = false
}
