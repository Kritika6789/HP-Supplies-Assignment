package test

import (
	"fmt"
	"testing"

	"github.azc.ext.hp.com/runway/terratest-lib/v3/pkg/commons"
	"github.com/gruntwork-io/terratest/modules/terraform"

	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func s3Replication(t *testing.T) {
	commons.CheckRequiredVariables(t, []string{
		"TF_VAR_region",
	})

	bucket1 := fmt.Sprintf("%s-us-west2", commons.GenerateUniqueName())
	bucket2 := fmt.Sprintf("%s-us-east1", commons.GenerateUniqueName())

	terraformOptions := &terraform.Options{
		TerraformDir: test_structure.CopyTerraformFolderToTemp(t, "../", "examples/create-s3-bucket-replication"),

		Vars: map[string]interface{}{
			"bucket1": bucket1,
			"bucket2": bucket2,
		},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}
	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)
}
