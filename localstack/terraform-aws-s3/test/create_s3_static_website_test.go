package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"

	"github.azc.ext.hp.com/runway/terratest-lib/v3/pkg/commons"

	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func s3StaticWebsite(t *testing.T) {
	commons.CheckRequiredVariables(t, []string{
		"TF_VAR_region",
	})

	bucketName := commons.GenerateUniqueName()

	terraformOptions := &terraform.Options{
		TerraformDir: test_structure.CopyTerraformFolderToTemp(t, "../", "examples/create-s3-bucket-with-static-website"),
		Vars: map[string]interface{}{
			"bucket": bucketName,
		},
		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}
	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	s3BucketName := terraform.Output(t, terraformOptions, "bucket")
	s3BucketARN := terraform.Output(t, terraformOptions, "arn")
	websiteEndpoint := terraform.Output(t, terraformOptions, "website_endpoint")
	websiteDomain := terraform.Output(t, terraformOptions, "website_domain")

	assert.NotEqual(t, "", s3BucketName, "S3 Bucket name should not be an empty string")
	assert.NotEqual(t, "", s3BucketARN, "S3 Bucket arn should not be an empty string")
	assert.NotEqual(t, "", websiteEndpoint, "S3 Bucket website_endpoint should not be an empty string")
	assert.NotEqual(t, "", websiteDomain, "S3 Bucket website_domain should not be an empty string")
}
