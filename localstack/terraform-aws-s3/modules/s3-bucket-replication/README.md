# AWS S3 Bucket Replication Module

This Terraform module creates one or more Cross-Region Replication configurations between S3 buckets on AWS, allowing
you to replicate objects between different S3 buckets.

It uses
the [S3 Bucket Replication Configuration resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration)
from the AWS provider. The module supports filtering based on exactly one of the following: prefix, tag, or a
combination of both (`and`), which can be used
to identify a subset of objects to which the replication rule applies.

## How to use this module?

This folder defines a [Terraform module](https://www.terraform.io/docs/modules/usage.html), which you can use in your
code by adding a module configuration and setting its source parameter to the URL of this folder:

### Terragrunt

```hcl
terraform {
  # Check releases for updates in this module
  source = "git::ssh://git@github.azc.ext.hp.com/runway/terraform-aws-s3.git//modules/s3-bucket-cross-region-replication?ref=master"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  source_bucket_name = "bucket1"
  destination_replication_configurations = {
    config1 = {
      destination_bucket_name    = "bucket2"
      status                     = "Enabled"
      delete_marker_replication  = "Enabled"
      filter                     = {}
    }
  }
}
```

### Terraform

```hcl
module "s3_bucket" {
  # Check releases for updates in this module
  source = "git::ssh://git@github.azc.ext.hp.com/runway/terraform-aws-s3.git//modules/s3-bucket-cross-region-replication?ref=master"

  source_bucket_name                     = "bucket1"
  destination_replication_configurations = {
    config1 = {
      destination_bucket_name   = "bucket2"
      status                    = "Enabled"
      delete_marker_replication = "Enabled"
      filter                    = {}
    }
  }
}
```

The module takes the following parameters:

* **source_bucket_name**: The name of the source bucket for replication.
* **destination_replication_configurations**: A map of replication configurations. Each configuration is a map with the
  following fields:
  - `destination_bucket_name`: The name of the destination bucket for replication (Required).
  - `status`: The status of the replication rule. Possible values are "Enabled" or "Disabled" (Required).
  - `delete_marker_replication`: Specifies whether to replicate delete markers. Possible values are "Enabled" or "
    Disabled".
  - `filter`: An object defining the filter for the replication rule. Can be empty or include exactly one of:
    - `prefix`: Object key name prefix that identifies the subset of objects to which the rule applies (Optional).
    - `tag`: Configuration block for specifying a tag key and value (Optional).
    - `and`: Configuration block for specifying rule filters with both prefix and tags (Optional).

## Cross-Account Configuration

The destination AWS account needs to have a bucket policy that allows the source account's replication role to write objects. Here's an example bucket policy for the destination bucket:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCrossAccountReplication",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::SOURCE-ACCOUNT-ID:role/REPLICATION-ROLE-NAME"
      },
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Resource": "arn:aws:s3:::DESTINATION-BUCKET-NAME/*"
    },
    {
      "Sid": "AllowCrossAccountReplicationConfiguration",
      "Effect": "Allow", 
      "Principal": {
        "AWS": "arn:aws:iam::SOURCE-ACCOUNT-ID:role/REPLICATION-ROLE-NAME"
      },
      "Action": [
        "s3:GetBucketVersioning",
        "s3:PutBucketVersioning"
      ],
      "Resource": "arn:aws:s3:::DESTINATION-BUCKET-NAME"
    }
  ]
}
```

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
| [aws_iam_role.s3_crr_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.s3_crr_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3_bucket_replication_configuration.s3_replication_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.s3_crr_role_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_destination_replication_configurations"></a> [destination\_replication\_configurations](#input\_destination\_replication\_configurations) | A map of replication configurations for the destination buckets. Each configuration is a map with the following fields:<br/>- destination\_bucket\_name: The name of the destination bucket for replication (Required).<br/>- destination\_account\_id: The AWS account ID of the destination bucket for cross-account replication (Optional). If not provided, defaults to the current account.<br/>- status: The status of the replication rule. Possible values are "Enabled" or "Disabled" (Required).<br/>- delete\_marker\_replication: Specifies whether to replicate delete markers. Possible values are "Enabled" or "Disabled" (Optional).<br/>- filter: An object defining the filter for the replication rule (Optional). Can include exactly one of:<br/>  - prefix: Object key name prefix that identifies the subset of objects to which the rule applies (Optional).<br/>  - tag: Configuration block for specifying a tag key and value (Optional).<br/>  - and: Configuration block for specifying rule filters with both prefix and tags (Optional).<br/><br/>Example Usage (without filtering):<br/>destination\_replication\_configurations = {<br/>  config1 = {<br/>    destination\_bucket\_name    = "bucket2"<br/>    status                     = "Enabled"<br/>    delete\_marker\_replication  = "Enabled"<br/>    filter                     = {}<br/>  }<br/>}<br/><br/>Example Usage (cross-account replication):<br/>destination\_replication\_configurations = {<br/>  cross\_account = {<br/>    destination\_bucket\_name    = "bucket2"<br/>    destination\_account\_id     = "123456789012"<br/>    status                     = "Enabled"<br/>    delete\_marker\_replication  = "Enabled"<br/>    filter                     = {}<br/>  }<br/>}<br/><br/>Example Usage (using prefix):<br/>destination\_replication\_configurations = {<br/>  config1 = {<br/>    destination\_bucket\_name    = "bucket2"<br/>    status                     = "Enabled"<br/>    delete\_marker\_replication  = "Enabled"<br/>    filter = {<br/>      prefix = "logs/"<br/>    }<br/>  }<br/>}<br/><br/>Example Usage (using tag):<br/>destination\_replication\_configurations = {<br/>  config2 = {<br/>    destination\_bucket\_name    = "bucket3"<br/>    status                     = "Disabled"<br/>    delete\_marker\_replication  = "Enabled"<br/>    filter = {<br/>      tag = {<br/>        key   = "Environment"<br/>        value = "Prod"<br/>      }<br/>    }<br/>  }<br/>}<br/><br/>Example Usage (using and):<br/>destination\_replication\_configurations = {<br/>  config3 = {<br/>    destination\_bucket\_name    = "bucket4"<br/>    status                     = "Enabled"<br/>    delete\_marker\_replication  = "Disabled"<br/>    filter = {<br/>      and = {<br/>        prefix = "data/"<br/>        tags   = {<br/>          Project = "Project1"<br/>          Owner   = "Owner1"<br/>        }<br/>      }<br/>    }<br/>  }<br/>} | `map(any)` | n/a | yes |
| <a name="input_role_name_prefix"></a> [role\_name\_prefix](#input\_role\_name\_prefix) | Creates a role name beginning with the specified prefix. | `string` | `"s3-replication"` | no |
| <a name="input_role_path"></a> [role\_path](#input\_role\_path) | IAM role path. | `string` | `"/"` | no |
| <a name="input_role_permissions_boundary"></a> [role\_permissions\_boundary](#input\_role\_permissions\_boundary) | The ARN of the policy that is used to set the permissions boundary for the user. | `string` | `null` | no |
| <a name="input_source_bucket_name"></a> [source\_bucket\_name](#input\_source\_bucket\_name) | The name of the source bucket for replication | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_replication_role_arn"></a> [replication\_role\_arn](#output\_replication\_role\_arn) | The ARN of the IAM role used for S3 replication |
| <a name="output_replication_role_name"></a> [replication\_role\_name](#output\_replication\_role\_name) | The name of the IAM role used for S3 replication |
<!-- END_TF_DOCS -->
