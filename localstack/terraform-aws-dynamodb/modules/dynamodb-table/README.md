<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_elasticsearch-cloudwatch-alarms"></a> [elasticsearch-cloudwatch-alarms](#module\_elasticsearch-cloudwatch-alarms) | git::ssh://git@github.azc.ext.hp.com/runway/terraform-aws-cloudwatch.git//modules/cloudwatch-alarms | v3.0.3 |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.dynamodb_table_read_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.dynamodb_table_read_policy_indexes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.dynamodb_table_write_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.dynamodb_table_write_policy_indexes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.dynamodb_table_read_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_appautoscaling_target.dynamodb_table_read_target_indexes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_appautoscaling_target.dynamodb_table_write_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_appautoscaling_target.dynamodb_table_write_target_indexes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_dynamodb_resource_policy.table_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_resource_policy) | resource |
| [aws_dynamodb_table.table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_alarms"></a> [additional\_alarms](#input\_additional\_alarms) | Object to create additional alarms | `map` | `{}` | no |
| <a name="input_additional_attributes"></a> [additional\_attributes](#input\_additional\_attributes) | Additional attributes for this DynamoDB table | <pre>list(object({<br/>    name = string<br/>    type = string<br/>  }))</pre> | `[]` | no |
| <a name="input_alarm_sns_topic_arn"></a> [alarm\_sns\_topic\_arn](#input\_alarm\_sns\_topic\_arn) | SNS topic ARN for the Cloudwatch Alarms created in this module | `string` | `""` | no |
| <a name="input_auto_scaling_enabled"></a> [auto\_scaling\_enabled](#input\_auto\_scaling\_enabled) | DynamoDB table autoscaling | `bool` | `true` | no |
| <a name="input_auto_scaling_read_max_capacity"></a> [auto\_scaling\_read\_max\_capacity](#input\_auto\_scaling\_read\_max\_capacity) | The autoscaling maximum read capacity | `number` | `40000` | no |
| <a name="input_auto_scaling_read_min_capacity"></a> [auto\_scaling\_read\_min\_capacity](#input\_auto\_scaling\_read\_min\_capacity) | The autoscaling minimun read capacity | `number` | `5` | no |
| <a name="input_auto_scaling_read_policy_target"></a> [auto\_scaling\_read\_policy\_target](#input\_auto\_scaling\_read\_policy\_target) | The autoscaling read target (%) value | `number` | `70` | no |
| <a name="input_auto_scaling_write_max_capacity"></a> [auto\_scaling\_write\_max\_capacity](#input\_auto\_scaling\_write\_max\_capacity) | The autoscaling maximum write capacity | `number` | `40000` | no |
| <a name="input_auto_scaling_write_min_capacity"></a> [auto\_scaling\_write\_min\_capacity](#input\_auto\_scaling\_write\_min\_capacity) | The autoscaling minimun write capacity | `number` | `5` | no |
| <a name="input_auto_scaling_write_policy_target"></a> [auto\_scaling\_write\_policy\_target](#input\_auto\_scaling\_write\_policy\_target) | The autoscaling write target (%) value | `number` | `70` | no |
| <a name="input_billing_mode"></a> [billing\_mode](#input\_billing\_mode) | Billing mode for the DynamoDB table. Either PROVISIONED or PAY\_PER\_REQUEST | `string` | `"PROVISIONED"` | no |
| <a name="input_deletion_protection_enabled"></a> [deletion\_protection\_enabled](#input\_deletion\_protection\_enabled) | Enable deletion protection | `bool` | `false` | no |
| <a name="input_enable_stream"></a> [enable\_stream](#input\_enable\_stream) | Enable DynamoDB Stream | `bool` | `false` | no |
| <a name="input_enable_ttl"></a> [enable\_ttl](#input\_enable\_ttl) | Indicates whether ttl is enabled (true) or disabled (false) | `bool` | `false` | no |
| <a name="input_global_secondary_indexes"></a> [global\_secondary\_indexes](#input\_global\_secondary\_indexes) | Describe GSIs for this DynamoDB table | <pre>list(object({<br/>    name               = string<br/>    hash_key           = string<br/>    range_key          = string<br/>    projection_type    = string<br/>    read_capacity      = number<br/>    write_capacity     = number<br/>    non_key_attributes = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_hash_key"></a> [hash\_key](#input\_hash\_key) | The attribute to use as the partition key of the DynamoDB table | `string` | n/a | yes |
| <a name="input_hash_key_type"></a> [hash\_key\_type](#input\_hash\_key\_type) | The key type. Either 'S', 'N' or 'B' for (S)tring, (N)umber or (B)inary data | `string` | `"S"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of the KMS key used to encrypt the table. If not set, the Default key is used. | `string` | `""` | no |
| <a name="input_local_secondary_indexes"></a> [local\_secondary\_indexes](#input\_local\_secondary\_indexes) | Describe LSIs for this DynamoDB table. Cannot change this definition after creation | <pre>list(object({<br/>    name               = string<br/>    range_key          = string<br/>    projection_type    = string<br/>    non_key_attributes = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_override_default_alarms"></a> [override\_default\_alarms](#input\_override\_default\_alarms) | Object to override default alarms | `map` | `{}` | no |
| <a name="input_point_in_time_recovery_enabled"></a> [point\_in\_time\_recovery\_enabled](#input\_point\_in\_time\_recovery\_enabled) | Whether to enable point-in-time recovery. It can take 10 minutes to enable for new tables. | `bool` | `false` | no |
| <a name="input_range_key"></a> [range\_key](#input\_range\_key) | The attribute to use as the sort key of the DynamoDB table | `string` | `null` | no |
| <a name="input_range_key_type"></a> [range\_key\_type](#input\_range\_key\_type) | The key type. Either 'S', 'N' or 'B' for (S)tring, (N)umber or (B)inary data | `string` | `"S"` | no |
| <a name="input_read_capacity"></a> [read\_capacity](#input\_read\_capacity) | The number of read units for this DynamoDB table | `number` | `5` | no |
| <a name="input_replica_configurations"></a> [replica\_configurations](#input\_replica\_configurations) | Configuration for replicas of the DynamoDB table<br/>* region\_name - Region name of the replica.<br/>* propagate\_tags - Whether to propagate the global table's tags to a replica. Default is false. Changes to tags only move in one direction: from global (source) to replica. In other words, tag drift on a replica will not trigger an update. Tag or replica changes on the global table, whether from drift or configuration changes, are propagated to replicas. Changing from true to false on a subsequent apply means replica tags are left as they were, unmanaged, not deleted.<br/>* point\_in\_time\_recovery - Whether to enable Point In Time Recovery for the replica.<br/>* kms\_key\_arn - ARN of the CMK that should be used for the AWS KMS encryption. This argument should only be used if the key is different from the default KMS-managed DynamoDB key<br/>  If a CMK is used in the primary table, each replica must also have an in region cmk specified. | <pre>list(object({<br/>    region_name            = string<br/>    propagate_tags         = bool<br/>    point_in_time_recovery = bool<br/>    kms_key_arn            = string<br/>  }))</pre> | `[]` | no |
| <a name="input_replica_regions"></a> [replica\_regions](#input\_replica\_regions) | [deprecated] Regions for creating replicas of the DynamoDB table | `list(string)` | `[]` | no |
| <a name="input_resource_policy"></a> [resource\_policy](#input\_resource\_policy) | A list of policies to attach to the DynamoDB table. | `string` | `""` | no |
| <a name="input_stream_view_type"></a> [stream\_view\_type](#input\_stream\_view\_type) | The type of data from the stream to be published. Valid values are KEYS\_ONLY, NEW\_IMAGE, OLD\_IMAGE, NEW\_AND\_OLD\_IMAGES | `string` | `"KEYS_ONLY"` | no |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | Name of the DynamoDB table | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add into all resources | `map(string)` | `{}` | no |
| <a name="input_ttl_attribute_name"></a> [ttl\_attribute\_name](#input\_ttl\_attribute\_name) | The name of the table attribute to store the TTL timestamp in | `string` | `"ttl"` | no |
| <a name="input_write_capacity"></a> [write\_capacity](#input\_write\_capacity) | The number of write units for this DynamoDB table | `number` | `5` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_stream_arn"></a> [stream\_arn](#output\_stream\_arn) | DynamoDB stream ARN |
| <a name="output_table_arn"></a> [table\_arn](#output\_table\_arn) | DynamoDB table ARN |
| <a name="output_table_id"></a> [table\_id](#output\_table\_id) | DynamoDB table ID |
<!-- END_TF_DOCS -->
