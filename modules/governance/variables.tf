variable "resource_group_id" { type = string }
variable "policy_definitions" { type = map(object({ display_name = string, policy_rule = string, parameters = optional(string) })) }
