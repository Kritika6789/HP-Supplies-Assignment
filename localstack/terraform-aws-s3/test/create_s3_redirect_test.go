package test

import (
	"fmt"
	"net/http"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"

	"github.azc.ext.hp.com/runway/terratest-lib/v3/pkg/commons"

	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func s3Redirect(t *testing.T) {
	commons.CheckRequiredVariables(t, []string{
		"TF_VAR_region",
	})

	domainName := fmt.Sprintf("%s-example.com", commons.GenerateUniqueName())

	terraformOptions := &terraform.Options{
		TerraformDir: test_structure.CopyTerraformFolderToTemp(t, "../", "examples/create-s3-redirect"),

		Vars: map[string]interface{}{
			"bucket": domainName,
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

	expectedRedirectUrl := "https://www.hp.com/us-en/shop/"
	assert.Equal(t, expectedRedirectUrl, getLocationResponseHeader(websiteEndpoint))
}

func getLocationResponseHeader(endpoint string) string {
	client := &http.Client {
		// As a special case, if CheckRedirect returns ErrUseLastResponse,
		// then the most recent response is returned with its body unclosed, along with a nil error.
		CheckRedirect: func(req *http.Request, via []*http.Request) error {
			return http.ErrUseLastResponse
		},
	}
	url := fmt.Sprintf("http://%s", endpoint)
	req, _ := http.NewRequest("GET", url, nil)
	res, err := client.Do(req)
	if err != nil {
		fmt.Println(err)
	}
	defer res.Body.Close()

	return res.Header.Get("Location")
}
