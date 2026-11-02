package test

import (
	"os"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/sts"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"

	"github.azc.ext.hp.com/runway/terratest-lib/v3/pkg/commons"

	awstt "github.com/gruntwork-io/terratest/modules/aws"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func createS3Bucket(t *testing.T) {
	commons.CheckRequiredVariables(t, []string{
		"TF_VAR_region",
	})

	awsRegion := os.Getenv("TF_VAR_region")
	bucketName := commons.GenerateUniqueName()

	terraformOptions := &terraform.Options{
		TerraformDir: test_structure.CopyTerraformFolderToTemp(t, "../", "examples/create-s3-bucket"),

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

	awstt.AssertS3BucketExists(t, awsRegion, bucketName)

	// Restrict TLS Policy should be set
	bucketPolicy, _ := awstt.GetS3BucketPolicyE(t, awsRegion, bucketName)

	restrictTLS10 := "\"Condition\":{\"NumericEquals\":{\"s3:TlsVersion\":\"1.0\"}}"
	restrictTLS11 := "\"Condition\":{\"NumericEquals\":{\"s3:TlsVersion\":\"1.1\"}}"

	assert.Contains(t, bucketPolicy, restrictTLS10)
	assert.Contains(t, bucketPolicy, restrictTLS11)

	// Versioning
	versioning := awstt.GetS3BucketVersioning(t, awsRegion, bucketName)
	assert.EqualValues(t, "Enabled", versioning)
}

func createS3WithPolicy(t *testing.T) {
	commons.CheckRequiredVariables(t, []string{
		"TF_VAR_region",
	})

	awsRegion := os.Getenv("TF_VAR_region")
	accountID := getAccountID(t, awsRegion)
	bucketName := commons.GenerateUniqueName()

	terraformOptions := &terraform.Options{
		TerraformDir: test_structure.CopyTerraformFolderToTemp(t, "../", "examples/create-s3-bucket"),

		Vars: map[string]interface{}{
			"bucket":           bucketName,
			"configure_policy": true,
			"account_id":       accountID,
		},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	awstt.AssertS3BucketExists(t, awsRegion, bucketName)

	// bucket policy
	policy := awstt.GetS3BucketPolicy(t, awsRegion, bucketName)
	assert.NotNil(t, policy)

	// versioning
	versioning := awstt.GetS3BucketVersioning(t, awsRegion, bucketName)
	assert.EqualValues(t, "Enabled", versioning)
}

func createS3WithLifeCycleRule(t *testing.T) {
	commons.CheckRequiredVariables(t, []string{
		"TF_VAR_region",
	})

	awsRegion := os.Getenv("TF_VAR_region")
	bucketName := commons.GenerateUniqueName()
	lifecycleRuleID := "rule1"
	lifecycleConfigEnabled := false
	lifecycleRulePrefix := "rule1/"
	lifecycleExpirationDays := 60
	lifecycleTransitionDays := 30
	lifecycleTransitionStorageClass := "STANDARD_IA"

	terraformOptions := &terraform.Options{
		TerraformDir: test_structure.CopyTerraformFolderToTemp(t, "../", "examples/create-s3-bucket"),

		// Variables to pass to Terraform code using -var options
		Vars: map[string]interface{}{
			"bucket":                             bucketName,
			"lifecycle_rule_id":                  lifecycleRuleID,
			"lifecycle_config_enabled":           lifecycleConfigEnabled,
			"lifecycle_rule_prefix":              lifecycleRulePrefix,
			"lifecycle_expiration_days":          lifecycleExpirationDays,
			"lifecycle_transition_days":          lifecycleTransitionDays,
			"lifecycle_transition_storage_class": lifecycleTransitionStorageClass,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	awstt.AssertS3BucketExists(t, awsRegion, bucketName)

	// versioning
	versioning := awstt.GetS3BucketVersioning(t, awsRegion, bucketName)
	assert.EqualValues(t, "Enabled", versioning)
	bucketPolicy, _ := awstt.GetS3BucketPolicyE(t, awsRegion, bucketName)

	// Restrict TLS Policy should be set
	restrictTLS10 := "\"Condition\":{\"NumericEquals\":{\"s3:TlsVersion\":\"1.0\"}}"
	restrictTLS11 := "\"Condition\":{\"NumericEquals\":{\"s3:TlsVersion\":\"1.1\"}}"

	assert.Contains(t, bucketPolicy, restrictTLS10)
	assert.Contains(t, bucketPolicy, restrictTLS11)

	// lifecycle config
	config := getBucketLifeCycleConfig(t, awsRegion, bucketName)
	assert.NotNil(t, config, "Bucket lifecycle config is null")

	if len((*config).Rules)  == 0 {
		t.Fatalf("Lifecycle rules not found")
	}

	rule := (*config).Rules[0]
	assert.Equal(t, lifecycleRuleID, *(rule.ID))
	assert.Equal(t, lifecycleRulePrefix, *(rule.Filter.Prefix))
	assert.Equal(t, int64(lifecycleExpirationDays), *(rule.Expiration.Days))
	assert.Equal(t, int64(lifecycleExpirationDays), *(rule.NoncurrentVersionExpiration.NoncurrentDays))
	assert.Equal(t, int64(lifecycleTransitionDays), *(rule.Transitions[0].Days))
	assert.Equal(t, lifecycleTransitionStorageClass, *(rule.Transitions[0].StorageClass))
}

func createS3WithServerSideEncryption(t *testing.T) {
	commons.CheckRequiredVariables(t, []string{
		"TF_VAR_region",
	})

	awsRegion := os.Getenv("TF_VAR_region")
	bucketName := commons.GenerateUniqueName()

	terraformOptions := &terraform.Options{
		TerraformDir: test_structure.CopyTerraformFolderToTemp(t, "../", "examples/create-s3-bucket"),

		Vars: map[string]interface{}{
			"bucket":                           bucketName,
			"configure_server_side_encryption": true,
		},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	awstt.AssertS3BucketExists(t, awsRegion, bucketName)
}

func createS3WithLoggingEnabled(t *testing.T) {
	commons.CheckRequiredVariables(t, []string{
		"TF_VAR_region",
	})

	awsRegion := os.Getenv("TF_VAR_region")
	bucketName := commons.GenerateUniqueName()

	terraformOptions := &terraform.Options{
		TerraformDir: test_structure.CopyTerraformFolderToTemp(t, "../", "examples/create-s3-bucket"),

		Vars: map[string]interface{}{
			"bucket":         bucketName,
			"enable_logging": true,
		},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// logging config
	config := getBucketLoggingConfig(t, awsRegion, bucketName)
	assert.NotNil(t, config, "Bucket logging config is null")

	loggingEnabled := (*config).LoggingEnabled
	assert.NotNil(t, loggingEnabled, "Logging Enabled is null")

	assert.Contains(t, *(loggingEnabled.TargetBucket), bucketName+"-access-logs")
	awstt.AssertS3BucketExists(t, awsRegion, bucketName)
	awstt.AssertS3BucketExists(t, awsRegion, bucketName+"-access-logs")
}

func createS3WithInventory(t *testing.T) {
	commons.CheckRequiredVariables(t, []string{
		"TF_VAR_region",
	})

	awsRegion := os.Getenv("TF_VAR_region")
	bucketName := commons.GenerateUniqueName()
	inventoryID := "daily-inventory"

	terraformOptions := &terraform.Options{
		TerraformDir: test_structure.CopyTerraformFolderToTemp(t, "../", "examples/create-s3-bucket"),

		Vars: map[string]interface{}{
			"bucket":             bucketName,
			"configure_inventory": true,
		},

		NoColor: true,
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	awstt.AssertS3BucketExists(t, awsRegion, bucketName)
	awstt.AssertS3BucketExists(t, awsRegion, bucketName+"-inventory")

	config := getBucketInventoryConfig(t, awsRegion, bucketName, inventoryID)
	assert.NotNil(t, config, "Bucket inventory config is null")
	assert.NotNil(t, config.InventoryConfiguration, "Inventory configuration is null")

	inventoryConfig := config.InventoryConfiguration
	assert.Equal(t, inventoryID, aws.StringValue(inventoryConfig.Id))
	assert.True(t, aws.BoolValue(inventoryConfig.IsEnabled))
	assert.Equal(t, "Current", aws.StringValue(inventoryConfig.IncludedObjectVersions))
	assert.Equal(t, "Daily", aws.StringValue(inventoryConfig.Schedule.Frequency))

	destination := inventoryConfig.Destination.S3BucketDestination
	assert.Equal(t, "CSV", aws.StringValue(destination.Format))
	assert.Equal(t, "", aws.StringValue(destination.Prefix))
	assert.Contains(t, aws.StringValue(destination.Bucket), bucketName+"-inventory")
}

func getBucketLifeCycleConfig(t *testing.T, awsRegion string, bucketName string) *s3.GetBucketLifecycleConfigurationOutput {
	// Create an AWS session
	sess, err := session.NewSession(&aws.Config{Region: aws.String(awsRegion)})
	if err != nil {
		t.Fatalf("Couldn't create a new AWS session: %v", err)
	}

	// Create S3 service client
	svc := s3.New(sess)

	input := &s3.GetBucketLifecycleConfigurationInput{
		Bucket: aws.String(bucketName),
	}

	result, err := svc.GetBucketLifecycleConfiguration(input)
	if err != nil {
		t.Fatalf("Couldn't get bucket lifecycle configuration: %v", err)
	}

	return result
}

func getBucketLoggingConfig(t *testing.T, awsRegion string, bucketName string) *s3.GetBucketLoggingOutput {
	// Create an AWS session
	sess, err := session.NewSession(&aws.Config{Region: aws.String(awsRegion)})
	if err != nil {
		t.Fatalf("Couldn't create a new AWS session: %v", err)
	}

	// Create S3 service client
	svc := s3.New(sess)

	input := &s3.GetBucketLoggingInput{
		Bucket: aws.String(bucketName),
	}

	result, err := svc.GetBucketLogging(input)
	if err != nil {
		t.Fatalf("Couldn't get bucket logging configuration: %v", err)
	}

	return result
}

func getBucketInventoryConfig(t *testing.T, awsRegion string, bucketName string, inventoryID string) *s3.GetBucketInventoryConfigurationOutput {
	sess, err := session.NewSession(&aws.Config{Region: aws.String(awsRegion)})
	if err != nil {
		t.Fatalf("Couldn't create a new AWS session: %v", err)
	}

	svc := s3.New(sess)

	input := &s3.GetBucketInventoryConfigurationInput{
		Bucket: aws.String(bucketName),
		Id:     aws.String(inventoryID),
	}

	result, err := svc.GetBucketInventoryConfiguration(input)
	if err != nil {
		t.Fatalf("Couldn't get bucket inventory configuration: %v", err)
	}

	return result
}

func getAccountID(t *testing.T, awsRegion string) string {
	// Create an AWS session
	sess, err := session.NewSession(&aws.Config{Region: aws.String(awsRegion)})
	if err != nil {
		t.Fatalf("Couldn't create a new AWS session: %v", err)
	}

	// Create STS service client
	svc := sts.New(sess)

	result, err := svc.GetCallerIdentity(&sts.GetCallerIdentityInput{})
	if err != nil {
		t.Fatalf("Couldn't get acccount id: %v", err)
	}

	return *result.Account
}
