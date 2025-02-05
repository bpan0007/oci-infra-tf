package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// An example of how to test the simple Terraform module in examples/terraform-basic-example using Terratest.
func TestTerraformBasicExampleUnique(t *testing.T) {
	t.Parallel()
	varsFilePath := "../../terraform.tfvars.json"
	println(varsFilePath)

	// expectedText := "test"
	// expectedList := []string{expectedText}
	// expectedMap := map[string]string{"expected": expectedText}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// website::tag::1::Set the path to the Terraform code that will be tested.
		// The path to where our Terraform code is located
		TerraformDir: "../modules/vcn",
		VarFiles:     []string{varsFilePath},
		// // Variables to pass to our Terraform code using -var options
		// Vars: map[string]interface{}{
		// 	"example": expectedText,

		// 	// We also can see how lists and maps translate between terratest and terraform.
		// 	"example_list": expectedList,
		// 	"example_map":  expectedMap,
		// },

		// // Variables to pass to our Terraform code using -var-file options
		// VarFiles: []string{"varfile.tfvars"},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	})

	// website::tag::4::Clean up resources with "terraform destroy". Using "defer" runs the command at the end of the test, whether the test succeeds or fails.
	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// website::tag::2::Run "terraform init" and "terraform apply".
	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables
	vcnID := terraform.Output(t, terraformOptions, "vcn_id")
	assert.NotEmpty(t, vcnID, "VCN ID should not be empty")

	// Test Public Subnet ID output
	publicSubnetID := terraform.Output(t, terraformOptions, "public_subnet_id")
	assert.NotEmpty(t, publicSubnetID, "Public subnet ID should not be empty")
	// Test subnets properties output
	subnetsMap := terraform.OutputMap(t, terraformOptions, "subnets_properties")

	// Test public subnet properties
	assert.Contains(t, subnetsMap, "public-subnet")
	publicSubnet := terraform.OutputMapOfObjects(t, terraformOptions, "subnets_properties")["public-subnet"]
	publicSubnetMap := publicSubnet.(map[string]interface{})
	assert.Equal(t, "10.0.0.0/24", publicSubnetMap["cidr_block"])
	assert.Equal(t, false, publicSubnetMap["prohibit_internet_ingress"])
	assert.Equal(t, false, publicSubnetMap["prohibit_public_ip_on_vnic"])
	assert.Equal(t, "AVAILABLE", publicSubnetMap["state"])

}
