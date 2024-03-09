resource "azurerm_resource_group" "resource_group" {
  for_each = local.resource_groups

  location = each.value.location

  name = each.value.name
  tags = each.value.tags

  lifecycle {
    ignore_changes = [
      tags["CreatedOnDate"]
    ]
  }
}

output "resource_groups" {
  value = var.enable_output ? azurerm_resource_group.resource_group[*] : null
}
