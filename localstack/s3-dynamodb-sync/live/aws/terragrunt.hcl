terraform {
  source = "../../..//s3-dynamodb-sync/terraform"
}

inputs = {
  aws_region    = get_env("AWS_REGION", "us-east-1")
  bucket_name   = get_env("SYNC_BUCKET_NAME", "replace-with-a-globally-unique-name")
  table_name    = get_env("SYNC_TABLE_NAME", "csv-records")
  localstack    = false
  force_destroy = false
  csv_prefix    = get_env("CSV_PREFIX", "")
}

remote_state {
  backend = "local"
  config = {
    path = "${get_terragrunt_dir()}/terraform.tfstate"
  }
}
