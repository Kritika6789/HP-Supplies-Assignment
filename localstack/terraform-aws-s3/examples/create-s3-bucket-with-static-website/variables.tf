variable "region" {
  default = "us-west-2"
}

variable "bucket" {
  description = "The name of the s3 bucket"
  default     = ""
}

variable "account_id" {
  default = ""
}

variable "configure_policy" {
  type    = bool
  default = false
}

variable "enable_logging" {
  default = false
}

variable "website_configuration" {
  default = {}
}
