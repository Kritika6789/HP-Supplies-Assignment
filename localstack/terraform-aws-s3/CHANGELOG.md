# Changelog

## v7.0.9

- Support AWS Global and AWS China partitions for bucket.

## 7.0

 - Set default bucket ownership to BucketOwnerEnforced

### Migration steps

 - Review your bucket for ACL permissions (`acl` parameter). IF you are using anything other than the default (`private`), you will need to migrate these permissions to a resource policy. Each of your existing bucket and object ACLs has an equivalent in an IAM policy. To understand which policy to use, see the following documents:
   - **Mapping of ACL permissions and access policy permissions**: https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-ownership-migrating-acls-prerequisites.html
   - **Prerequisites for disabling ACLs**: https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-ownership-migrating-acls-prerequisites.html

## 6.3

- Support for `bucket_key_enabled` [Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration#bucket_key_enabled)

## 6.2

- Support role path for the `s3-replication` module
- Support role permissions boundary for the `s3-replication` module
- Support customizing the role name for the `s3-replication` module

## 6.1

- Support AWS other partitions

## 6.0

- Change minimum AWS provider version to 4.0.0. 
- Change how `abort_incomplete_multipart_upload` is defined. 

### Fixes
- [Issue 34](https://github.azc.ext.hp.com/runway/terraform-aws-s3/issues/34)
- [Issue 36](https://github.azc.ext.hp.com/runway/terraform-aws-s3/issues/36)


## 5.0

- Updated deprecated parameters from S3 bucket resource
- `server_side_encryption_configuration` attribute default value changed from `null` to `[]`
- `website_configuration` attribute type changed from `list(any)` to `map(any)`. Its default value changed from `null` to `{}`. Its value should follow the argument reference section from **aws_s3_bucket_website_configuration** resource.
- `access_log_bucket_server_side_encryption_configuration` attribute default value changed from `null` to `[]`
- The standalone attributes for S3 bucket CORS configuration were removed: `aliases`, `external_aliases`, `cors_allowed_headers`, `cors_allowed_methods`, `cors_allowed_origins`, `cors_expose_headers`, `cors_max_age_seconds`.
- `cors_rules` attribute added to handle S3 bucket CORS configuration. Its value should follow the argument reference section from **aws_s3_bucket_cors_configuration** resource.

### Migration Steps

In order to adopt the new standalone resources and stop using the deprecated parameters form **aws_s3_bucket** resource some changes on the attributes were necessary.

The most significant changes are related to: S3 Bucket CORS Configuration and  S3 Bucket Website Configuration. Checkout the corresponding section to see a more detailed comparison on the changes.

### S3 Bucket CORS Configuration

<table>
<tr>
<th>Before</th>
<th>Now</th>
</tr>
<tr>
<td>

```hcl
cors_allowed_headers = ["*"]
cors_allowed_methods = ["PUT", "POST"]
cors_allowed_origins = ["https://s3-website-test.hashicorp.com"]
cors_expose_headers  = ["ETag"]
cors_max_age_seconds = 3000
```

</td>

<td>

```hcl
cors_rules = [{
  allowed_headers = ["*"]
  allowed_methods = ["PUT", "POST"]
  allowed_origins = ["https://s3-website-test.hashicorp.com"]
  expose_headers  = ["ETag"]
  max_age_seconds = 3000
}]
```

</td>
</tr>
</table>


### S3 Bucket Website Configuration: Static Website

<table>
<tr>
<th>Before</th>
<th>Now</th>
</tr>
<tr>
<td>

```hcl
website_configuration = [{
  index_document = "index.html"
  error_document = "error.html"
}]
```

</td>

<td>

```hcl
website_configuration = {
  index_document = "index.html"
  error_document = "error.html"
}
```

</td>
</tr>
</table>

### S3 Bucket Website Configuration: Redirect

<table>
<tr>
<th>Before</th>
<th>Now</th>
</tr>
<tr>
<td>

```hcl
redirect = "https://www.hp.com/us-en/shop"
```

</td>

<td>

```hcl
website_configuration = {
  redirect_all_requests_to = {
    host_name = "www.hp.com/us-en/shop"
    protocol  = "https"
  }
}
```

</td>
</tr>
</table>

## 3.1

- Defined the policy to Restrict TLS 1.1, and TLS 1.2 by default when create a new S3 bucket

## 3.0

- Migration to Terraform 0.13
- Added Provisioning Policy
