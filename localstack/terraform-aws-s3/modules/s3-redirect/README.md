<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | ../../modules/s3-bucket | n/a |
| <a name="module_s3_bucket_www"></a> [s3\_bucket\_www](#module\_s3\_bucket\_www) | ../../modules/s3-bucket | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain"></a> [domain](#input\_domain) | Original domain | `string` | n/a | yes |
| <a name="input_redirect"></a> [redirect](#input\_redirect) | URL that it should be redirect to | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname |
| <a name="output_hosted_zone_id"></a> [hosted\_zone\_id](#output\_hosted\_zone\_id) | The Route 53 Hosted Zone ID for this bucket's region. |
| <a name="output_id"></a> [id](#output\_id) | The name of the s3 bucket |
| <a name="output_website_domain"></a> [website\_domain](#output\_website\_domain) | The domain of the website endpoint |
| <a name="output_www_arn"></a> [www\_arn](#output\_www\_arn) | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname |
| <a name="output_www_hosted_zone_id"></a> [www\_hosted\_zone\_id](#output\_www\_hosted\_zone\_id) | The Route 53 Hosted Zone ID for this bucket's region (for initial 'www' domain). |
| <a name="output_www_id"></a> [www\_id](#output\_www\_id) | The name of the s3 bucket (for initial 'www' domain) |
| <a name="output_www_website_domain"></a> [www\_website\_domain](#output\_www\_website\_domain) | The domain of the website endpoint (for initial 'www' domain). |
<!-- END_TF_DOCS -->