package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"

	"github.azc.ext.hp.com/runway/terratest-lib/v3/pkg/commons"

	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func createS3SqsNotification(t *testing.T) {
	commons.CheckRequiredVariables(t, []string{
		"TF_VAR_region",
	})

	sqsName := commons.GenerateUniqueName()
	bucketName := commons.GenerateUniqueName()

	terraformOptions := &terraform.Options{
		TerraformDir: test_structure.CopyTerraformFolderToTemp(t, "../", "examples/create-s3-sqs-notification"),
		Vars: map[string]interface{}{
			"bucket":  bucketName,
			"sqsname": sqsName,
		},
		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}
	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)
}
