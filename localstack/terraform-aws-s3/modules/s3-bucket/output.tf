output "bucket" {
  value       = var.bucket
  description = "The name of the s3 bucket"
}

output "arn" {
  value       = aws_s3_bucket.bucket.arn
  description = "The ARN of the bucket. Will be of format arn:<partition>:s3:::bucketname"
}

output "id" {
  value       = aws_s3_bucket.bucket.id
  description = "The id of the bucket -  also the name of the bucket"
}

output "access_logs_bucket" {
  value       = var.enable_logging ? local.access_logs_bucket : null
  description = "The name of bucket storing the access logs"
}

output "access_log_bucket_arn" {
  value       = length(aws_s3_bucket.access_log_bucket) > 0 ? aws_s3_bucket.access_log_bucket[0].arn : null
  description = "The arn of bucket storing the access logs"
}

output "access_log_bucket_id" {
  value       = length(aws_s3_bucket.access_log_bucket) > 0 ? aws_s3_bucket.access_log_bucket[0].id : null
  description = "The id of bucket storing the access logs"
}

output "bucket_domain_name" {
  value       = aws_s3_bucket.bucket.bucket_domain_name
  description = "The bucket domain name. Will be of format bucketname.s3.$${data.aws_partition.current.dns_suffix}."
}

output "bucket_regional_domain_name" {
  value       = aws_s3_bucket.bucket.bucket_regional_domain_name
  description = "The bucket region-specific domain name."
}

output "hosted_zone_id" {
  value       = aws_s3_bucket.bucket.hosted_zone_id
  description = "The Route 53 Hosted Zone ID for this bucket's region."
}

output "region" {
  value       = aws_s3_bucket.bucket.region
  description = "The AWS region this bucket resides in."
}

output "website_endpoint" {
  value       = length(keys(var.website_configuration)) == 0 ? "" : aws_s3_bucket_website_configuration.bucket_website_config[0].website_endpoint
  description = "The website endpoint, if the bucket is configured with a website. If not, this will be an empty string."
}

output "website_domain" {
  value       = length(keys(var.website_configuration)) == 0 ? "" : aws_s3_bucket_website_configuration.bucket_website_config[0].website_domain
  description = "The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records."
}
