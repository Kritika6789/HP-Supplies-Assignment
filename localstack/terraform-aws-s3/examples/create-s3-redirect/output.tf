output "bucket" {
  value       = module.s3_redirect.id
  description = "The name of the s3 bucket"
}

output "arn" {
  value       = module.s3_redirect.arn
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname"
}

output "website_domain" {
  value       = module.s3_redirect.website_domain
  description = "The domain of the website endpoint"
}

output "website_endpoint" {
  value       = module.s3_redirect.website_endpoint
  description = "The website endpoint"
}
