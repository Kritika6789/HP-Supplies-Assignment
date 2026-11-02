output "id" {
  value       = module.s3_bucket.id
  description = "The id of the bucket -  also the name of the bucket"
}

output "arn" {
  value       = module.s3_bucket.arn
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname"
}
