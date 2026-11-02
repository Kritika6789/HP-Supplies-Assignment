# Tests

This folder contains automated tests for this module. Before running the tests, review [these instructions](https://pages.github.azc.ext.hp.com/runway/community/learn/tests/) to prepare your environment correctly and to understand the overall test strategy adopted in RunWay for integration tests.


## Environment Variables

```bash
export GOPRIVATE="github.azc.ext.hp.com"
export TF_VAR_region="xxx"
```

## Run Tests

To run ALL tests:

```bash
cd test
go test -v -timeout 60m
```

To run a specific test called `TestFoo`:

```bash
cd test
go test -v -timeout 60m -run TestTerraformModules//TestFoo
```
