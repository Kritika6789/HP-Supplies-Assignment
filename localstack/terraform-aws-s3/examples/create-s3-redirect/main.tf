provider "aws" {
  region = var.region
}

module "s3_redirect" {
  source = "../../modules/s3-bucket"
  bucket = var.bucket
  acl    = "private"
  website_configuration = {
    redirect_all_requests_to = {
      host_name = "www.hp.com/us-en/shop"
      protocol  = "https"
    }
  }
}
