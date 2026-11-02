/*
 * (C) Copyright 2019-2020 HP Development Company, L.P.
 * Confidential computer software. Valid license from HP required for possession, use or copying.
 * Consistent with FAR 12.211 and 12.212, Commercial Computer Software,
 * Computer Software Documentation, and Technical Data for Commercial Items are licensed
 * to the U.S. Government under vendor's standard commercial license.
 */

locals {
  account_id = data.aws_caller_identity.current.account_id
  policy     = var.create_integration_tests_policy ? data.aws_iam_policy_document.test.json : data.aws_iam_policy_document.policy.json
}

resource "aws_iam_policy" "policy" {
  count = var.create_policy ? 1 : 0

  name_prefix = "RunwayS3ProvisionerPolicy"
  description = "Runway policy for provisioning terraform-aws-s3 modules"
  policy      = local.policy
  path        = var.policy_path
}
