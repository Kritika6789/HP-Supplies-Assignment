
# RunWay Terraform AWS DynamoDB Module

[![Build Status](https://dev.azure.com/hpcodeway/RunWay/_apis/build/status/runway.terraform-aws-dynamodb?branchName=master)](https://dev.azure.com/hpcodeway/RunWay/_build/latest?definitionId=1041&branchName=master)

_After creating a new module from this template and establishing an ADO pipeline connection, the build status badge will need to be updated. [Here are instructions on how to find this.](https://docs.microsoft.com/en-us/azure/devops/pipelines/create-first-pipeline?view=azure-devops&tabs=java%2Cyaml%2Cbrowser%2Ctfs-2018-2#add-a-status-badge-to-your-repository)_

Modules in Terraform are self-contained packages of Terraform configurations that are managed as a group. Modules are used to create reusable components in Terraform as well as for basic code organization. Please review the Terraform documentation to become familiar with Modules: https://www.terraform.io/docs/modules/usage.html

This repo contains the following folder structure:

* [modules](./modules) contain several standalone, reusable, production-grade modules.
* [examples](./examples) contain examples that combine the modules in the `modules` folder to deploy real infrastructure.
* [resources](./resources) contain resources for the modules, most notably the recommended provisioning policies.
* [test](./test) contain integration tests for the modules and examples.

## Requirements

1. Install [Terraform](https://www.terraform.io/downloads.html).
1. For scripting requirements, please use [Python3](https://www.python.org/downloads/).
1. For integration tests, please refer to the test requirements documented at [test/README.md](/test/README.md).

### Supported Operating Systems:

- [Linux](https://www.linux.org/)
- [Windows](https://www.microsoft.com/en-us/windows)

## Modules

For additional parameters you can use to customize each module, please read the `README.md` inside the module and check out the `examples/` folder for working sample code.

* [dynamodb-table](./modules/dynamodb-table/README.md) creates a DynamoDB table.

## Issues

### Bugs

If you have found a bug please follow the instructions below:

- Spend a small amount of time giving due diligence to the issue tracker. Your issue might be a duplicate.
- Open a [new issue](../../issues/new).
- Inform what module version you are using.
- Paste in the issue the `terraform.tfvars` that you are using.
- Paste in the issue the `terraform plan` and `terraform apply` output.
- Remember, users might be searching for your issue in the future, so please give it a meaningful title to helps others.

### Features

If you have an idea for a new feature follow the steps below.

- Open a [new issue](../../issues/new).
- Remember, users might be searching for your issue in the future, so please give it a meaningful title to helps others.
- Clearly define the use case, using concrete examples. EG: I type `this` and gdrsctl does `that`.
- If you would like to include a technical design for your feature please include it in the issue.
- Feel free to code it yourself, open up a **WIP** *(work in progress)* pull request, and happy coding.

## Contributing

Pull requests are welcome on GitHub. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributors' Guide](https://pages.github.azc.ext.hp.com/runway/community/contribute/).
