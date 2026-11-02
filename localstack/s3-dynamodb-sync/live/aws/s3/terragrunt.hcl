include "backend" {
  path = find_in_parent_folders("common_backend.hcl")
}

terraform {
  source = "../../../../terraform-aws-s3/modules/s3-bucket"
}

inputs = {
  bucket        = get_env("SYNC_BUCKET_NAME", "kritika-csv-sync-apsouth2-20261014")
  force_destroy = false
  enforce_tls   = true
}
