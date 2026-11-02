<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket_notification.bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the s3 bucket | `string` | n/a | yes |
| <a name="input_filter_prefix"></a> [filter\_prefix](#input\_filter\_prefix) | Filter notifications on the prefix | `string` | `"AWSLogs/"` | no |
| <a name="input_filter_suffix"></a> [filter\_suffix](#input\_filter\_suffix) | Filter notifications on the suffix | `string` | `".log"` | no |
| <a name="input_lambda_arn"></a> [lambda\_arn](#input\_lambda\_arn) | The arn of the Lambda function | `string` | n/a | yes |
| <a name="input_s3_event"></a> [s3\_event](#input\_s3\_event) | The event when Notification needs to be sent | `list(any)` | <pre>[<br/>  "s3:ObjectCreated:*"<br/>]</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->