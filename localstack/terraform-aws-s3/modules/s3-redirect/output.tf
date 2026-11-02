output "id" {
  value       = module.s3_bucket.id
  description = "The name of the s3 bucket"
}

output "www_id" {
  value       = module.s3_bucket_www.id
  description = "The name of the s3 bucket (for initial 'www' domain)"
}

output "arn" {
  value       = module.s3_bucket.arn
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname"
}

output "www_arn" {
  value       = module.s3_bucket_www.arn
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname"
}

output "website_domain" {
  value       = module.s3_bucket.website_domain
  description = "The domain of the website endpoint"
}

output "www_website_domain" {
  value       = module.s3_bucket_www.website_domain
  description = "The domain of the website endpoint (for initial 'www' domain)."
}

output "hosted_zone_id" {
  value       = module.s3_bucket.hosted_zone_id
  description = "The Route 53 Hosted Zone ID for this bucket's region."
}

output "www_hosted_zone_id" {
  value       = module.s3_bucket_www.hosted_zone_id
  description = " The Route 53 Hosted Zone ID for this bucket's region (for initial 'www' domain). "
}


