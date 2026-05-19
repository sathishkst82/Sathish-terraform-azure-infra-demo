resource "azurerm_policy_definition" "deny_public_ip" {
  name         = "deny-public-ip"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deny Public IP"
  policy_rule  = file("${path.root}/governance/deny-public-ip-policy.json")
}

resource "azurerm_policy_set_definition" "baseline" {
  name         = "Opella-Governance-Baseline"
  policy_type  = "Custom"
  display_name = "Opella Governance Baseline"

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.deny_public_ip.id
  }
}

resource "azurerm_resource_group_policy_assignment" "baseline" {
  name                 = "opella-governance-assignment"
  resource_group_id    = var.resource_group_id
  policy_definition_id = azurerm_policy_set_definition.baseline.id
}
