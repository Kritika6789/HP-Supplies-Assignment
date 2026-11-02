/*
 * (C) Copyright 2019-2021 HP Development Company, L.P.
 * Confidential computer software. Valid license from HP required for possession, use or copying.
 * Consistent with FAR 12.211 and 12.212, Commercial Computer Software,
 * Computer Software Documentation, and Technical Data for Commercial Items are licensed
 * to the U.S. Government under vendor's standard commercial license.
 */

variable "region" {
  default = "us-west-2"
}

variable "table_name" {
  default = "Reply"
}

variable "kms_identifiers" {
  type    = list(string)
  default = ["*"]
}
