variable "bucket" {
  type        = string
  description = "The name of the s3 bucket"
}

variable "versioning_enabled" {
  type        = bool
  default     = true
  description = "Once you version-enabled, the bucket can never return to an unversioned state and can only be suspended"
}

variable "acl" {
  type        = string
  default     = "private"
  description = "The [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl) to apply"
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error"
}

variable "policy" {
  type        = string
  description = "A valid bucket policy JSON document."
  default     = null
}

variable "lifecycle_rules" {
  type        = any
  description = "List of maps containing configuration of object lifecycle management."
  default     = []
}

variable "server_side_encryption_configuration" {
  type        = list(any)
  description = <<DESCRIPTION
  Example:
  server_side_encryption_configuration = {
    bucket_key_enabled = true
    kms_master_key_id = aws_kms_key.objects.arn
    sse_algorithm     = "aws:kms"
  }
  DESCRIPTION
  default     = []
}

variable "website_configuration" {
  type        = map(any)
  description = <<DESCRIPTION
  Provides an S3 bucket website configuration resource.
  More info at argument reference section from aws_s3_bucket_website_configuration resource.

  Examples:

   - for static websites
  website_configuration = {
    index_document = "index.html"
    error_document = "error.html"
  }

   - for redirection
  website_configuration = {
    redirect_all_requests_to = {
      host_name = 'example.com/a/b.html'
      protocol  = 'https'
    }
  }
  DESCRIPTION
  default     = {}
}

variable "cors_rules" {
  type        = list(any)
  description = <<DESCRIPTION
  Provides an S3 bucket CORS configuration resource.
  More info at argument reference section from aws_s3_bucket_cors_configuration resource.

  Examples:

   - default settings
  cors_rules = [{
    allowed_origins = ["https://s3-website-test.hashicorp.com"]
  }]

   - customized settings
  cors_rules = [{
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["https://s3-website-test.hashicorp.com"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }]
  DESCRIPTION
  default     = []
}

variable "inventory_configurations" {
  type = map(object({
    enabled                  = optional(bool)
    included_object_versions = optional(string)
    optional_fields          = optional(list(string))
    schedule_frequency       = optional(string)
    filter_prefix            = optional(string)
    destination = optional(object({
      bucket_arn = optional(string)
      format     = optional(string)
      prefix     = optional(string)
      account_id = optional(string)
      encryption = optional(object({
        sse_kms_key_id = optional(string)
        sse_s3         = optional(bool)
      }))
    }))
  }))
  description = <<DESCRIPTION
  Optional map of S3 inventory configurations.
  Each item configures one aws_s3_bucket_inventory resource.

  Example:
  inventory_configurations = {
    daily-inventory = {
    enabled                  = true
    included_object_versions = "Current"
    optional_fields          = ["Size", "LastModifiedDate", "StorageClass"]
    schedule_frequency       = "Daily"
    filter_prefix            = ""
    destination = {
      bucket_arn = "arn:<partition>:s3:::my-inventory-destination-bucket"
      format     = "CSV"
      prefix     = "inventory/"
      account_id = "123456789012"
      encryption = {
        sse_s3 = true
      }
    }
    }
  }
  DESCRIPTION
  default     = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "enable_logging" {
  description = "Enable access logs of the bucket"
  type        = bool
  default     = false
}

variable "access_log_bucket_force_destroy" {
  type        = bool
  default     = false
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error."
}

variable "access_log_bucket_policy" {
  type        = string
  default     = null
  description = "A valid bucket policy JSON document."
}

variable "access_log_bucket_lifecycle_rules" {
  type        = any
  default     = []
  description = <<DESCRIPTION
  List of maps containing configuration of object lifecycle management.
  Example:
  [{
    id      = "Time to live"
    prefix  = "/"
    enabled = true

    expirations = [{
      days = 30
      },
    ]

    transitions = [{
      days = 30
      storage_class = "STANDARD_IA"
      },
    ]
  }]
  DESCRIPTION
}

variable "access_log_bucket_server_side_encryption_configuration" {
  type        = list(any)
  description = <<DESCRIPTION
  Example:
  access_log_bucket_server_side_encryption_configuration = {
    bucket_key_enabled = true
    kms_master_key_id = aws_kms_key.objects.arn
    sse_algorithm     = "aws:kms"
  }
  DESCRIPTION
  default     = []
}

variable "object_ownership" {
  description = "Object ownership. Valid values: BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter. If BucketOwnerEnforced is set, ACL is disabled and acl parameter is ignored"
  type        = string
  default     = "BucketOwnerEnforced"
}


variable "private_access" {
  description = "Blocks public access. Only used when object_ownership is set to BucketOwnerEnforced"
  type        = bool
  default     = true
}

variable "enforce_tls" {
  description = "Attach the default bucket policy requiring HTTPS requests."
  type        = bool
  default     = true
}