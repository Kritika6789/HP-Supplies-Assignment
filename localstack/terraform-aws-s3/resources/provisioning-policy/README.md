# Provisioning Policy Module

This folder contains a [Terraform](https://www.terraform.io/) module that creates an IAM policy document following the least privilege principle to define the required permissions to create, update and destroy the resources described in the collection of modules available in this repository. 

## How to use this module?

Used either in other Runway modules to compose new policies or in conjunction with the [runway-role](https://github.azc.ext.hp.com/runway/terraform-aws-iam/tree/master/modules/runway-role) to create an IAM role ready for provisioning Runway modules via Codeway pipelines.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| create\_integration\_tests\_policy | Flag to enable or disable creating supplementary policies for testing this module. | `bool` | `false` | no |
| create\_policy | Flag to enable or disable creating the provisioning policy. | `bool` | `true` | no |
| name\_prefix | The name prefix used by the services managed by the policies. | `string` | n/a | yes |
| policy\_path | IAM policy path. | `string` | `"/runway/"` | no |
| role\_path | IAM role path. | `string` | `"/runway/"` | no |

## Outputs

| Name | Description |
|------|-------------|
| policy\_arn | The policy ARN. |
| policy\_document | The policy document in JSON format. |
