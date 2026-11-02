include "backend" {
  path = find_in_parent_folders("common_backend.hcl")
}

terraform {
  source = "../../../../terraform-aws-s3/modules/s3-bucket"
}

inputs = {
  bucket        = get_env("SYNC_BUCKET_NAME", "csv-sync-bucket")
  force_destroy = true
  enforce_tls   = false
}
