locals { policy_names = [for p in azurerm_policy_definition.this : p.name] }
resource "azurerm_policy_definition" "this" {
  for_each     = var.policy_definitions
  name         = each.key
  policy_type  = "Custom"
  mode         = "All"
  display_name = each.value.display_name
  policy_rule  = each.value.policy_rule
  parameters   = lookup(each.value, "parameters", null)
}
resource "azurerm_policy_set_definition" "baseline" {
  name         = "Opella-Governance-Baseline"
  policy_type  = "Custom"
  display_name = "Opella Governance Baseline"
  dynamic "policy_definition_reference" {
    for_each = azurerm_policy_definition.this
    content { policy_definition_id = policy_definition_reference.value.id reference_id = policy_definition_reference.key }
  }
}
resource "azurerm_resource_group_policy_assignment" "this" {
  name                 = "opella-governance-assignment"
  resource_group_id    = var.resource_group_id
  policy_definition_id = azurerm_policy_set_definition.baseline.id
}
