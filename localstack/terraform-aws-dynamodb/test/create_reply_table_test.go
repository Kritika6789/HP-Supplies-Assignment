package test

import (
	"os"
	"testing"

	"github.azc.ext.hp.com/runway/terratest-lib/v3/pkg/commons"

	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"

	awsSDK "github.com/aws/aws-sdk-go/aws"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func createReplyTable(t *testing.T) {
	t.Parallel()
	commons.CheckRequiredVariables(t, []string{
		"TF_VAR_region",
	})

	tableName := commons.GenerateUniqueName()
	region := os.Getenv("TF_VAR_region")
	attributes := []*dynamodb.AttributeDefinition{
		{AttributeName: awsSDK.String("Id"), AttributeType: awsSDK.String("S")},
		{AttributeName: awsSDK.String("ReplyDateTime"), AttributeType: awsSDK.String("S")},
		{AttributeName: awsSDK.String("PostedBy"), AttributeType: awsSDK.String("S")},
		{AttributeName: awsSDK.String("Message"), AttributeType: awsSDK.String("S")},
	}
	keySchema := []*dynamodb.KeySchemaElement{
		{AttributeName: awsSDK.String("Id"), KeyType: awsSDK.String("HASH")},
		{AttributeName: awsSDK.String("ReplyDateTime"), KeyType: awsSDK.String("RANGE")},
	}

	terraformOptions := &terraform.Options{
		TerraformDir: test_structure.CopyTerraformFolderToTemp(t, "../", "examples/create-reply-table"),

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"table_name": tableName,
		},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Look up the DynamoDB table by name
	table := aws.GetDynamoDBTable(t, region, tableName)

	assert.Equal(t, "ACTIVE", awsSDK.StringValue(table.TableStatus))
	assert.ElementsMatch(t, keySchema, table.KeySchema)
	assert.ElementsMatch(t, attributes, table.AttributeDefinitions)
}
