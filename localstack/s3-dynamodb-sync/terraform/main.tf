provider "aws" {
  region                      = var.aws_region
  access_key                  = var.localstack ? "test" : null
  secret_key                  = var.localstack ? "test" : null
  skip_credentials_validation = var.localstack
  skip_metadata_api_check     = var.localstack
  skip_region_validation      = var.localstack
  skip_requesting_account_id  = var.localstack
  s3_use_path_style           = var.localstack

  dynamic "endpoints" {
    for_each = var.localstack ? [1] : []
    content {
      s3       = var.localstack_endpoint
      dynamodb = var.localstack_endpoint
      events   = var.localstack_endpoint
      iam      = var.localstack_endpoint
      lambda   = var.localstack_endpoint
      sts      = var.localstack_endpoint
    }
  }
}

module "bucket" {
  source        = "../../terraform-aws-s3/modules/s3-bucket"
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
  enforce_tls   = !var.localstack
  tags          = var.tags
}

module "table" {
  source                         = "../../terraform-aws-dynamodb/modules/dynamodb-table"
  table_name                     = var.table_name
  hash_key                       = "source_key"
  hash_key_type                  = "S"
  range_key                      = "row_number"
  range_key_type                 = "N"
  billing_mode                   = "PAY_PER_REQUEST"
  auto_scaling_enabled           = false
  enable_alarms                  = false
  point_in_time_recovery_enabled = false
  tags                           = var.tags
}

module "csv_sync" {
  source                     = "./modules/csv-sync"
  bucket_name                = module.bucket.bucket
  bucket_arn                 = module.bucket.arn
  table_name                 = var.table_name
  table_arn                  = module.table.table_arn
  aws_region                 = var.aws_region
  localstack                 = var.localstack
  lambda_localstack_endpoint = var.lambda_localstack_endpoint
  csv_prefix                 = var.csv_prefix
}
