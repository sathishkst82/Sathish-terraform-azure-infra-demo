package tests

import (
  "testing"
  "github.com/gruntwork-io/terratest/modules/terraform"
  "github.com/stretchr/testify/assert"
)

func TestVnetModule(t *testing.T) {
  opts := &terraform.Options{TerraformDir: "../environments/dev", NoColor: true}
  terraform.InitAndPlan(t, opts)
  rg := terraform.Output(t, opts, "resource_group_name")
  assert.Contains(t, rg, "rg-opella-dev")
}
