/*
 * (C) Copyright 2019-2020 HP Development Company, L.P.
 * Confidential computer software. Valid license from HP required for possession, use or copying.
 * Consistent with FAR 12.211 and 12.212, Commercial Computer Software,
 * Computer Software Documentation, and Technical Data for Commercial Items are licensed
 * to the U.S. Government under vendor's standard commercial license.
 */

output "policy_document" {
  description = "The policy document in JSON format."
  value       = data.aws_iam_policy_document.policy.json
}

output "policy_arn" {
  description = "The policy ARN."
  value       = length(aws_iam_policy.policy) > 0 ? aws_iam_policy.policy[0].arn : ""
}
