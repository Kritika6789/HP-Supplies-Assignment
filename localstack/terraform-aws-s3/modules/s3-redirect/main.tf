module "s3_bucket_www" {
  source = "../../modules/s3-bucket"
  bucket = "www.${var.domain}"
  acl    = "private"
  website_configuration = {
    redirect_all_requests_to = {
      host_name = var.redirect
    }
  }
}

module "s3_bucket" {
  source = "../../modules/s3-bucket"
  bucket = var.domain
  acl    = "private"
  website_configuration = {
    redirect_all_requests_to = {
      host_name = var.redirect
    }
  }
}
