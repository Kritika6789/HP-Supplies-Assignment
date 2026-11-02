# AWS S3 Bucket SQS Notification Module

This folder contains a [Terraform](https://www.terraform.io/) module that can be used to create a SQS notification for an AWS S3 bucket.

## How to use this module?

```hcl

module "s3_bucket_notification" {
  # Check releases for updates in this module
  source = "git::ssh://git@github.azc.ext.hp.com/runway/terraform-aws-s3.git//modules/s3-notification-sqs?ref=1.0.0"

  bucket_name   = "runway-s3-bucket-example-lifecycle"
  topic_arn     = "arn:aws:sqs:us-east-2:444455556666:queue"
  s3_event      = ["s3:ObjectCreated:*"]
  filter_suffix = ".log"
}
```

Note the following parameter:

* **source**: Use this parameter to specify the URL of the module. The double slash (//) is intentional and required. Terraform uses it to specify subfolders within a Git repo (see module sources). The ref parameter specifies a specific Git tag in this repo. That way, instead of using the latest version of this module from the master branch, which will change every time you run Terraform, you're using a fixed version of the repo.

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
| <a name="input_filter_prefix"></a> [filter\_prefix](#input\_filter\_prefix) | Object key name prefix. | `string` | `null` | no |
| <a name="input_filter_suffix"></a> [filter\_suffix](#input\_filter\_suffix) | Object key name suffix. | `string` | `".log"` | no |
| <a name="input_s3_event"></a> [s3\_event](#input\_s3\_event) | The event when Notification needs to be sent | `list(any)` | <pre>[<br/>  "s3:ObjectCreated:*"<br/>]</pre> | no |
| <a name="input_sqs_arn"></a> [sqs\_arn](#input\_sqs\_arn) | SQS queue ARN. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
