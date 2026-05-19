package tests

import (
  "testing"
  "github.com/gruntwork-io/terratest/modules/terraform"
)

func TestVnetModule(t *testing.T) {
  opts := &terraform.Options{TerraformDir: "../environments/dev", NoColor: true}
  terraform.Init(t, opts)
  out := terraform.Output(t, opts, "vnet_id")
  if out == "" { t.Fatalf("expected vnet_id output") }
}
