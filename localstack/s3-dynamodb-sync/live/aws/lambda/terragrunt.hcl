include "backend" {
  path = find_in_parent_folders("common_backend.hcl")
}

terraform {
  source = "../../../..//s3-dynamodb-sync/terraform/modules/csv-sync"
}

dependency "s3" {
  config_path = "../s3"
  mock_outputs = {
    bucket = "mock-s3-bucket"
    arn    = "arn:aws:s3:::mock-s3-bucket"
  }
}

dependency "dynamodb" {
  config_path = "../dynamodb"
  mock_outputs = {
    table_id  = "mock-table"
    table_arn = "arn:aws:dynamodb:us-east-1:123456789012:table/mock-table"
  }
}

inputs = {
  aws_region                 = get_env("AWS_REGION", "ap-southeast-2")
  bucket_name                = dependency.s3.outputs.bucket
  bucket_arn                 = dependency.s3.outputs.arn
  table_name                 = dependency.dynamodb.outputs.table_id
  table_arn                  = dependency.dynamodb.outputs.table_arn
  localstack                 = false
  lambda_localstack_endpoint = ""
  csv_prefix                 = get_env("CSV_PREFIX", "")
}
