package test

import (
	"testing"

	"github.azc.ext.hp.com/runway/terratest-lib/v3/pkg/aws"
)

func TestTerraformModules(t *testing.T) {
	t.Parallel()

	testCases := []struct {
		name     string
		testCode func(*testing.T)
	}{
		{"CreateS3Bucket", createS3Bucket},
		{"CreateS3WithPolicy", createS3WithPolicy},
		{"CreateS3WithLifeCycleRule", createS3WithLifeCycleRule},
		{"CreateS3WithServerSideEncryption", createS3WithServerSideEncryption},
		{"CreateS3WithLoggingEnabled", createS3WithLoggingEnabled},
		{"CreateS3WithInventory", createS3WithInventory},
		{"CreateS3SnsNotification", createS3SnsNotification},
		{"CreateS3SqsNotification", createS3SqsNotification},
		{"S3StaticWebsite", s3StaticWebsite},
		{"S3Redirect", s3Redirect},
		{"s3Replication", s3Replication},
	}

	// Test environment setup, might be different depending on the cloud provider you're using
	// For AWS, this creates an IAM user using the module's provisioning policy
	// This user is used during the tests and it is removed once the tests finish
	aws.NewIamUser(t, "resources/provisioning-policy", true)

	t.Run("group", func(t *testing.T) {
		for _, testCase := range testCases {
			// To avoid the range variable from getting updated in the parallel tests,
			// we bind a new name that is within the scope of the for block.
			testCase := testCase

			t.Run(testCase.name, func(t *testing.T) {
				testCase.testCode(t)
			})
		}
	})
}
