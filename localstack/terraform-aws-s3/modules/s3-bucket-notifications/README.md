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
| [aws_s3_bucket_notification.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the S3 bucket | `string` | n/a | yes |
| <a name="input_lambda_notifications"></a> [lambda\_notifications](#input\_lambda\_notifications) | List of Lambda notification configurations | <pre>list(object({<br/>    lambda_function_arn = string<br/>    events              = list(string)<br/>    filter_prefix       = optional(string)<br/>    filter_suffix       = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_queue_notifications"></a> [queue\_notifications](#input\_queue\_notifications) | List of SQS queue notification configurations | <pre>list(object({<br/>    queue_arn     = string<br/>    events        = list(string)<br/>    filter_prefix = optional(string)<br/>    filter_suffix = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_topic_notifications"></a> [topic\_notifications](#input\_topic\_notifications) | List of SNS topic notification configurations | <pre>list(object({<br/>    topic_arn     = string<br/>    events        = list(string)<br/>    filter_prefix = optional(string)<br/>    filter_suffix = optional(string)<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
