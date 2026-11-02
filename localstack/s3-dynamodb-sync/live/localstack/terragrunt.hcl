terraform {
  source = "../../..//s3-dynamodb-sync/terraform"
}

inputs = {
  aws_region                 = get_env("AWS_REGION", "us-east-1")
  bucket_name                = get_env("SYNC_BUCKET_NAME", "csv-sync-bucket")
  table_name                 = get_env("SYNC_TABLE_NAME", "csv-records")
  localstack                 = true
  force_destroy              = true
  localstack_endpoint        = get_env("LOCALSTACK_ENDPOINT", "http://localhost:4566")
  lambda_localstack_endpoint = get_env("LAMBDA_LOCALSTACK_ENDPOINT", "http://host.docker.internal:4566")
  csv_prefix                 = get_env("CSV_PREFIX", "")
}

remote_state {
  backend = "local"
  config = {
    path = "${get_terragrunt_dir()}/terraform.tfstate"
  }
}
