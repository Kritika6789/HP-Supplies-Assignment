include "backend" {
  path = find_in_parent_folders("common_backend.hcl")
}

terraform {
  source = "../../../..//s3-dynamodb-sync/terraform/modules/csv-sync"
}

dependency "s3" {
  config_path = "../s3"
  mock_outputs = {
    bucket = "csv-sync-bucket"
    arn    = "arn:aws:s3:::csv-sync-bucket"
  }
}

dependency "dynamodb" {
  config_path = "../dynamodb"
  mock_outputs = {
    table_id  = "csv-records"
    table_arn = "arn:aws:dynamodb:us-east-1:000000000000:table/csv-records"
  }
}

inputs = {
  aws_region                 = get_env("AWS_REGION", "us-east-1")
  bucket_name                = dependency.s3.outputs.bucket
  bucket_arn                 = dependency.s3.outputs.arn
  table_name                 = dependency.dynamodb.outputs.table_id
  table_arn                  = dependency.dynamodb.outputs.table_arn
  localstack                 = true
  localstack_endpoint        = get_env("LOCALSTACK_ENDPOINT", "http://localhost:4566")
  lambda_localstack_endpoint = get_env("LAMBDA_LOCALSTACK_ENDPOINT", "http://host.docker.internal:4566")
  csv_prefix                 = get_env("CSV_PREFIX", "")
}
