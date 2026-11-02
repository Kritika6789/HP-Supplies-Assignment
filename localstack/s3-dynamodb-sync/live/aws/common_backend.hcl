remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = get_env("TG_STATE_BUCKET", "kritika-terraform-state-apsouth2-20261014")
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = get_env("AWS_REGION", "ap-southeast-2")
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
