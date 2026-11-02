output "bucket" {
  value       = module.s3_bucket.id
  description = "The name of the s3 bucket"
}

output "arn" {
  value       = module.s3_bucket.arn
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname"
}

output "website_endpoint" {
  value       = module.s3_bucket.website_endpoint
  description = "The website endpoint, if the bucket is configured with a website. If not, this will be an empty string."
}

output "website_domain" {
  value       = module.s3_bucket.website_domain
  description = "The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records."
}
