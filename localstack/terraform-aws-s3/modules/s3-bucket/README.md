# AWS S3 Bucket Module

Terraform module which creates S3 bucket resources on AWS.

Provides a S3 bucket resource.
* [S3](https://www.terraform.io/docs/providers/aws/r/s3_bucket.html)

These S3 Bucket configurations are supported:

- lifecycle-rules
- versioning
- policy
- server side encryption
- inventory


## How to use this module?

This folder defines a [Terraform module](https://www.terraform.io/docs/modules/usage.html), which you can use in your code by adding a module configuration and setting its source parameter to URL of this folder:

### Terragrunt
```hcl

terraform {
  # Check releases for updates in this module
  source = "git::ssh://git@github.azc.ext.hp.com/runway/terraform-aws-s3.git//modules/s3-bucket?ref=master"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  bucket             = "runway-s3-bucket-example"
  versioning_enabled = true
  acl                = "private"

  lifecycle_rules = [
    {
      id      = "rule1"
      enabled = true
      prefix  = "rule1/"

      expiration = {
          days = 90
      }

      transition = [
        {
          days = 30
          storage_class = "STANDARD_IA"
        },
      ]
    }
  ]
}

```

### Terraform
```hcl

module "s3_bucket" {
  # Check releases for updates in this module
  source = "git::ssh://git@github.azc.ext.hp.com/runway/terraform-aws-s3.git//modules/s3-bucket?ref=master"

  bucket             = "runway-s3-bucket-example-lifecycle"
  versioning_enabled = true
  acl                = "private"

  lifecycle_rules = [
    {
      id      = "rule1"
      enabled = true
      prefix  = "rule1/"

      expiration = {
          days = 90
      }
    },
    {
      id      = "rule2"
      enabled = true
      prefix  = "rule2/"

      expiration = {
          days = 90
      }
    },
  ]

  server_side_encryption_configuration = [{
    sse_algorithm = "AES256"
  }]

  inventory_configurations = {
    daily-inventory = {
      included_object_versions = "Current"
      optional_fields          = ["Size", "LastModifiedDate", "StorageClass"]
      schedule_frequency       = "Daily"
    }
  }
}
```

Note the following parameter:

* **source**: Use this parameter to specify the URL of the module. The double slash (//) is intentional and required. Terraform uses it to specify subfolders within a Git repo (see module sources). The ref parameter specifies a specific Git tag in this repo. That way, instead of using the latest version of this module from the master branch, which will change every time you run Terraform, you're using a fixed version of the repo.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.access_log_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_acl.bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_cors_configuration.bucket_cors_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_inventory.bucket_inventory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_inventory) | resource |
| [aws_s3_bucket_lifecycle_configuration.accces_logs_lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.bucket_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_ownership_controls.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_ownership_controls.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.access_log_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.inventory_destination_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.acl_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.access_log_bucket_server_side_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.bucket_server_side_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_website_configuration.bucket_website_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.empty](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.inventory_destination_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_tls_enforcement](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_log_bucket_force_destroy"></a> [access\_log\_bucket\_force\_destroy](#input\_access\_log\_bucket\_force\_destroy) | A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. | `bool` | `false` | no |
| <a name="input_access_log_bucket_lifecycle_rules"></a> [access\_log\_bucket\_lifecycle\_rules](#input\_access\_log\_bucket\_lifecycle\_rules) | List of maps containing configuration of object lifecycle management.<br/>  Example:<br/>  [{<br/>    id      = "Time to live"<br/>    prefix  = "/"<br/>    enabled = true<br/><br/>    expirations = [{<br/>      days = 30<br/>      },<br/>    ]<br/><br/>    transitions = [{<br/>      days = 30<br/>      storage\_class = "STANDARD\_IA"<br/>      },<br/>    ]<br/>  }] | `any` | `[]` | no |
| <a name="input_access_log_bucket_policy"></a> [access\_log\_bucket\_policy](#input\_access\_log\_bucket\_policy) | A valid bucket policy JSON document. | `string` | `null` | no |
| <a name="input_access_log_bucket_server_side_encryption_configuration"></a> [access\_log\_bucket\_server\_side\_encryption\_configuration](#input\_access\_log\_bucket\_server\_side\_encryption\_configuration) | Example:<br/>  access\_log\_bucket\_server\_side\_encryption\_configuration = {<br/>    bucket\_key\_enabled = true<br/>    kms\_master\_key\_id = aws\_kms\_key.objects.arn<br/>    sse\_algorithm     = "aws:kms"<br/>  } | `list(any)` | `[]` | no |
| <a name="input_acl"></a> [acl](#input\_acl) | The [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl) to apply | `string` | `"private"` | no |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | The name of the s3 bucket | `string` | n/a | yes |
| <a name="input_cors_rules"></a> [cors\_rules](#input\_cors\_rules) | Provides an S3 bucket CORS configuration resource.<br/>  More info at argument reference section from aws\_s3\_bucket\_cors\_configuration resource.<br/><br/>  Examples:<br/><br/>   - default settings<br/>  cors\_rules = [{<br/>    allowed\_origins = ["https://s3-website-test.hashicorp.com"]<br/>  }]<br/><br/>   - customized settings<br/>  cors\_rules = [{<br/>    allowed\_headers = ["*"]<br/>    allowed\_methods = ["PUT", "POST"]<br/>    allowed\_origins = ["https://s3-website-test.hashicorp.com"]<br/>    expose\_headers  = ["ETag"]<br/>    max\_age\_seconds = 3000<br/>  }] | `list(any)` | `[]` | no |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | Enable access logs of the bucket | `bool` | `false` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error | `bool` | `false` | no |
| <a name="input_inventory_configurations"></a> [inventory\_configurations](#input\_inventory\_configurations) | Optional map of S3 inventory configurations.<br/>  Each item configures one aws\_s3\_bucket\_inventory resource.<br/><br/>  Example:<br/>  inventory\_configurations = {<br/>    daily-inventory = {<br/>    enabled                  = true<br/>    included\_object\_versions = "Current"<br/>    optional\_fields          = ["Size", "LastModifiedDate", "StorageClass"]<br/>    schedule\_frequency       = "Daily"<br/>    filter\_prefix            = ""<br/>    destination = {<br/>      bucket\_arn = "arn:<partition>:s3:::my-inventory-destination-bucket"<br/>      format     = "CSV"<br/>      prefix     = "inventory/"<br/>      account\_id = "123456789012"<br/>      encryption = {<br/>        sse\_s3 = true<br/>      }<br/>    }<br/>    }<br/>  } | <pre>map(object({<br/>    enabled                  = optional(bool)<br/>    included_object_versions = optional(string)<br/>    optional_fields          = optional(list(string))<br/>    schedule_frequency       = optional(string)<br/>    filter_prefix            = optional(string)<br/>    destination = optional(object({<br/>      bucket_arn = optional(string)<br/>      format     = optional(string)<br/>      prefix     = optional(string)<br/>      account_id = optional(string)<br/>      encryption = optional(object({<br/>        sse_kms_key_id = optional(string)<br/>        sse_s3         = optional(bool)<br/>      }))<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | List of maps containing configuration of object lifecycle management. | `any` | `[]` | no |
| <a name="input_object_ownership"></a> [object\_ownership](#input\_object\_ownership) | Object ownership. Valid values: BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter. If BucketOwnerEnforced is set, ACL is disabled and acl parameter is ignored | `string` | `"BucketOwnerEnforced"` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | A valid bucket policy JSON document. | `string` | `null` | no |
| <a name="input_private_access"></a> [private\_access](#input\_private\_access) | Blocks public access. Only used when object\_ownership is set to BucketOwnerEnforced | `bool` | `true` | no |
| <a name="input_server_side_encryption_configuration"></a> [server\_side\_encryption\_configuration](#input\_server\_side\_encryption\_configuration) | Example:<br/>  server\_side\_encryption\_configuration = {<br/>    bucket\_key\_enabled = true<br/>    kms\_master\_key\_id = aws\_kms\_key.objects.arn<br/>    sse\_algorithm     = "aws:kms"<br/>  } | `list(any)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Once you version-enabled, the bucket can never return to an unversioned state and can only be suspended | `bool` | `true` | no |
| <a name="input_website_configuration"></a> [website\_configuration](#input\_website\_configuration) | Provides an S3 bucket website configuration resource.<br/>  More info at argument reference section from aws\_s3\_bucket\_website\_configuration resource.<br/><br/>  Examples:<br/><br/>   - for static websites<br/>  website\_configuration = {<br/>    index\_document = "index.html"<br/>    error\_document = "error.html"<br/>  }<br/><br/>   - for redirection<br/>  website\_configuration = {<br/>    redirect\_all\_requests\_to = {<br/>      host\_name = 'example.com/a/b.html'<br/>      protocol  = 'https'<br/>    }<br/>  } | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_log_bucket_arn"></a> [access\_log\_bucket\_arn](#output\_access\_log\_bucket\_arn) | The arn of bucket storing the access logs |
| <a name="output_access_log_bucket_id"></a> [access\_log\_bucket\_id](#output\_access\_log\_bucket\_id) | The id of bucket storing the access logs |
| <a name="output_access_logs_bucket"></a> [access\_logs\_bucket](#output\_access\_logs\_bucket) | The name of bucket storing the access logs |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the bucket. Will be of format arn:<partition>:s3:::bucketname |
| <a name="output_bucket"></a> [bucket](#output\_bucket) | The name of the s3 bucket |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | The bucket domain name. Will be of format bucketname.s3.${data.aws\_partition.current.dns\_suffix}. |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name) | The bucket region-specific domain name. |
| <a name="output_hosted_zone_id"></a> [hosted\_zone\_id](#output\_hosted\_zone\_id) | The Route 53 Hosted Zone ID for this bucket's region. |
| <a name="output_id"></a> [id](#output\_id) | The id of the bucket -  also the name of the bucket |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this bucket resides in. |
| <a name="output_website_domain"></a> [website\_domain](#output\_website\_domain) | The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records. |
| <a name="output_website_endpoint"></a> [website\_endpoint](#output\_website\_endpoint) | The website endpoint, if the bucket is configured with a website. If not, this will be an empty string. |
<!-- END_TF_DOCS -->
