provider "aws" {
  region = var.region
}

module "s3_bucket" {
  source = "../../modules/s3-bucket"

  bucket = var.bucket
  policy = var.configure_policy == true ? data.aws_iam_policy_document.policy.json : null

  website_configuration = {
    index_document = "index.html"
    error_document = "error.html"
  }

  enable_logging   = var.enable_logging
  object_ownership = "BucketOwnerEnforced"
}


data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.bucket}",
      "arn:aws:s3:::${var.bucket}/*",
    ]

    principals {
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
      type        = "AWS"
    }
  }

}
