/*
 * (C) Copyright 2019-2020 HP Development Company, L.P.
 * Confidential computer software. Valid license from HP required for possession, use or copying.
 * Consistent with FAR 12.211 and 12.212, Commercial Computer Software,
 * Computer Software Documentation, and Technical Data for Commercial Items are licensed
 * to the U.S. Government under vendor's standard commercial license.
 */

variable "name_prefix" {
  description = "The name prefix used by the services managed by the policies."
  type        = string
}

variable "role_path" {
  description = "IAM role path."
  default     = "/"
  type        = string
}

variable "policy_path" {
  description = "IAM policy path."
  default     = "/"
  type        = string
}

variable "create_policy" {
  description = "Flag to enable or disable creating the provisioning policy."
  default     = true
  type        = bool
}

variable "create_integration_tests_policy" {
  description = "Flag to enable or disable creating supplementary policies for testing this module."
  default     = false
  type        = bool
}
