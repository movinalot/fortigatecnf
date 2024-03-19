resource "azurerm_user_assigned_identity" "user_assigned_identity" {
  for_each = local.user_assigned_identities

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name = each.value.name
}

output "user_assigned_identities" {
  value = var.enable_output ? azurerm_user_assigned_identity.user_assigned_identity[*] : null
}
