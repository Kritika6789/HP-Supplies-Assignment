# Changelog

## 3.0
- Add support for KMS-CMK
- Add support for point-in-time recovery
### Breaking changes
- `replica_regions` is deprecated and will be removed in the next major version. Use replica_configurations instead. Example below.
```
replica_regions = [
    "us-west-2"
]
```
Equivalent configuration:
```
replica_configurations = [
    {
        region_name = "us-west-2"
        propagate_tags = false        
        point_in_time_recovery = false
        kms_key_arn = ""
    }
]
```

## 2.0

- Code refactor including:
    - Single module to create DynamoDB tables
    - Ability to set additional attributes
    - Ability to set LSIs and GSIs
    - Ability to set CloudWatch Alarms
 