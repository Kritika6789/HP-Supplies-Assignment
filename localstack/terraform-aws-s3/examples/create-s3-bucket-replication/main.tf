provider "aws" {
  region = var.region
}

module "s3_bucket1" {
  source = "../../modules/s3-bucket"

  bucket = var.bucket1

  object_ownership   = "BucketOwnerEnforced"
  versioning_enabled = true
}

module "s3_bucket2" {
  source = "../../modules/s3-bucket"

  bucket = var.bucket2

  object_ownership   = "BucketOwnerEnforced"
  versioning_enabled = true
}

module "s3_replication_configuration" {
  source = "../../modules/s3-bucket-replication"

  source_bucket_name = module.s3_bucket1.id

  destination_replication_configurations = {
    config1 = {
      destination_bucket_name   = module.s3_bucket2.id
      status                    = "Enabled"
      delete_marker_replication = "Enabled"
      filter                    = {}
    }
  }

  depends_on = [module.s3_bucket1, module.s3_bucket2]
}
